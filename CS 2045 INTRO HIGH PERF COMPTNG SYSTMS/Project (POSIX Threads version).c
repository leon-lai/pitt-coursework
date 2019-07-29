/* ------------------------------------------------------------------------ *\
	CLASS   :  2191 CS 2045 SEC1020 INTRO HIGH PERF COMPTNG SYSTMS
	AUTHOR  :  Leon Lai <Leon.Lai@pitt.edu>
	TITLE   :  2-D Poisson's equation solver (POSIX Threads version)
	DATE    :  2018-11-19
\* ------------------------------------------------------------------------ */

#include <float.h>        /* DECIMAL_DIG */
#include <math.h>         /* expl fabsl INFINITY */
#include <pthread.h>
#include <stdio.h>        /* fclose fopen fprintf NULL printf setbuf stderr stdout */
#include <stdlib.h>       /* strtold strtoull */
#include <sys/time.h>     /* [POSIX not ISO] gettimeofday timeval */

static long double DELTA(
	long double const a,
	long double const b,
	unsigned long long const n)
{
	return (b - a) / (n - 1);
}

static long double negative_inverse_square_DELTA(
	long double const a,
	long double const b,
	unsigned long long const n)
{
	return -1.0L / (DELTA(a, b, n) * DELTA(a, b, n));
}

static long double x_from_i(
	unsigned long long const i,
	long double const a,
	long double const b,
	unsigned long long const n)
{
	return a + i * DELTA(a, b, n);
}

static unsigned long long l_from_nXY(
	unsigned long long const nX,
	unsigned long long const nY)
{
	return nX * nY;
}

static unsigned long long j_from_iXY(
	unsigned long long const iX,
	unsigned long long const nX,
	unsigned long long const iY)
{
	/* Cf. iX + nX * iY + nX * nY * iZ */
	return iX + nX * iY;
}

int print_vtk_1(
	FILE * const stream,
	char const * const title,
	unsigned long long const nX,
	unsigned long long const nY)
{
	/* Return value. */
	int rv = 0;

	/* ------ End of variable declarations; start of procedures. ------ */

	rv += fprintf(stream, "# vtk DataFile Version 2.0\n");
	rv += fprintf(stream, "%s\n", title);
	rv += fprintf(stream, "ASCII\n");
	rv += fprintf(stream, "DATASET STRUCTURED_GRID\n");
	rv += fprintf(stream, "DIMENSIONS %llu %llu %llu\n", nX, nY, 1ULL);
	rv += fprintf(stream, "POINTS %llu float\n", l_from_nXY(nX, nY));
	return rv;
}

int print_vtk_2(
	FILE * const stream,
	long double const aX,
	long double const aY,
	long double const bX,
	long double const bY,
	unsigned long long const nX,
	unsigned long long const nY)
{
	/* Variables for use in iterations. */
	unsigned long long iX, iY;

	/* Return value. */
	int rv = 0;

	/* ------ End of variable declarations; start of procedures. ------ */

	for (iY = 0; iY <= nY-1; ++iY) {
		for (iX = 0; iX <= nX-1; ++iX) {
			rv += fprintf(stream, "%Lf %Lf %Lf\n",
				x_from_i(iX, aX, bX, nX),
				x_from_i(iY, aY, bY, nY),
				0.0L);
		}
	}
	return rv;
}

int print_vtk_3(
	FILE * const stream,
	char const * const dataName,
	unsigned long long const nX,
	unsigned long long const nY)
{
	/* Return value. */
	int rv = 0;

	/* ------ End of variable declarations; start of procedures. ------ */

	rv += fprintf(stream, "POINT_DATA %llu\n", l_from_nXY(nX, nY));
	rv += fprintf(stream, "SCALARS %s float 1\n", dataName);
	rv += fprintf(stream, "LOOKUP_TABLE default\n");
	return rv;
}

int print_vtk_4(
	FILE * const stream,
	unsigned long long const nX,
	unsigned long long const nY,
	long double const * const vector)
{
	/* Variables for use in iterations. */
	unsigned long long iX, iY;

	/* Return value. */
	int rv = 0;

	/* ------ End of variable declarations; start of procedures. ------ */

	for (iY = 0; iY <= nY-1; ++iY) {
		for (iX = 0; iX <= nX-1; ++iX) {
			rv += fprintf(stream, "%Lf\n",
				vector[j_from_iXY(iX, nX, iY)]);
		}
	}
	return rv;
}

/**
 * @return 2 if invalid argument.
 */
int point_gridcoord_block_from_proc_coord(
	unsigned long long const num_proc_coord,
	unsigned long long const proc_coord,
	unsigned long long const num_point_coord,
	unsigned long long const skirt,
	unsigned long long * const block_min_point_gridcoord,
	unsigned long long * const block_max_point_gridcoord)
{
	if (proc_coord >= num_proc_coord) return 2;
	if (num_point_coord < num_proc_coord) return 2;
	*block_min_point_gridcoord =
		skirt +
		(num_point_coord - skirt*2)*proc_coord/num_proc_coord
		- skirt;
	*block_max_point_gridcoord =
		skirt +
		(num_point_coord - skirt*2)*(proc_coord+1)/num_proc_coord - 1
		+ skirt;
	return 0;
}

void leonpthread_allreduce_max_long_double(
	long double * const x,
	pthread_mutex_t * const mutex,
	pthread_barrier_t * const barrier)
{
	static long double y = 0;
	static char first = 1;

	pthread_mutex_lock(mutex);
	if (first) {
		y = *x;
		first = 0;
	} else {
		y = (*x > y) ? *x : y;
	}
	pthread_mutex_unlock(mutex);
	pthread_barrier_wait(barrier);
	*x = y;                        /* No race. */
	first = 1;                     /* No race. */
	pthread_barrier_wait(barrier); /* Prevents race due to next round. */
}

static long double Tans_verification(
	long double const x,
	long double const y)
{
	return x * expl(y);
}

static long double source1(
	long double const x,
	long double const y)
{
	return x * expl(y);
}

static long double source2()
{
	return 0.2;
}

static long double boundary_value1(
	long double const x,
	long double const y)
{
	return x * expl(y);
}

static long double boundary_value2()
{
	return 0;
}

int project_init_0(
	unsigned long long const nX,
	unsigned long long const nY,
	long double * * const S,
	long double * * const T,
	long double * * const T2)
{
	if (!(*S = malloc(l_from_nXY(nX, nY) * sizeof **S)))
		return 2;
	if (!(*T = malloc(l_from_nXY(nX, nY) * sizeof **T)))
		return 2;
	if (!(*T2 = malloc(l_from_nXY(nX, nY) * sizeof **T2)))
		return 2;
	return 0;
}

/**
 * Sets the source and boundary values.
 */
int project_init_1(
	long double (* const source_function)(
		long double const x,
		long double const y),
	long double (* const boundary_value_function)(
		long double const x,
		long double const y),
	long double const aX,
	long double const aY,
	long double const bX,
	long double const bY,
	unsigned long long const nX,
	unsigned long long const nY,
	unsigned long long const mX,
	unsigned long long const mY,
	unsigned long long const wX,
	unsigned long long const wY,
	long double * const S,
	long double * const T,
	long double * const T2)
{
	unsigned long long aiX, aiY, biX, biY;

	/* ------ End of variable declarations; start of procedures. ------ */

	if (point_gridcoord_block_from_proc_coord(mX, wX, nX, 0, &aiX, &biX))
		return 2;
	if (point_gridcoord_block_from_proc_coord(mY, wY, nY, 0, &aiY, &biY))
		return 2;

	for (unsigned long long iY = aiY; iY <= biY; ++iY) {
		for (unsigned long long iX = aiX; iX <= biX; ++iX) {
			unsigned long long const j = j_from_iXY(iX, nX, iY);
			S[j] = source_function(
				x_from_i(iX, aX, bX, nX),
				x_from_i(iY, aY, bY, nY));
			T[j] = (
				iX == 0 || iX == nX - 1 ||
				iY == 0 || iY == nY - 1
			) ? boundary_value_function(
				x_from_i(iX, aX, bX, nX),
				x_from_i(iY, aY, bY, nY)) : 0;
			T2[j] = T[j];
		}
	}

	return 0;
}

struct project_init_1_bundle {
	long double (* source_function)(
		long double const x,
		long double const y);
	long double (* boundary_value_function)(
		long double const x,
		long double const y);
	long double aX;
	long double aY;
	long double bX;
	long double bY;
	unsigned long long nX;
	unsigned long long nY;
	unsigned long long mX;
	unsigned long long mY;
	unsigned long long wX;
	unsigned long long wY;
	long double * S;
	long double * T;
	long double * T2;
};

void * project_init_1_run(
	void * argument)
{
	struct project_init_1_bundle const * const bundle =
		(struct project_init_1_bundle const *) argument;
	project_init_1(
		bundle->source_function,
		bundle->boundary_value_function,
		bundle->aX,
		bundle->aY,
		bundle->bX,
		bundle->bY,
		bundle->nX,
		bundle->nY,
		bundle->mX,
		bundle->mY,
		bundle->wX,
		bundle->wY,
		bundle->S,
		bundle->T,
		bundle->T2);
	return NULL;
}

int project_iter(
	long double const * const S,
	long double * * const T_arg,
	long double * * const T2_arg,
	long double const aX,
	long double const aY,
	long double const bX,
	long double const bY,
	unsigned long long const nX,
	unsigned long long const nY,
	unsigned long long const mX,
	unsigned long long const mY,
	unsigned long long const wX,
	unsigned long long const wY,
	long double const max_maxnorm_iterdiff,
	FILE * const prog_stream,
	pthread_mutex_t * const allreduce_mutex,
	pthread_barrier_t * const allreduce_barrier)
{
	/* Coefficients for Jacobi/Gauss-Seidel 2D PE solving. */
	const long double coeff_s_XY = (1.0L / 2.0L) / (
		negative_inverse_square_DELTA(aX, bX, nX)
		+
		negative_inverse_square_DELTA(aY, bY, nY)
	);
	const long double coeff_DELTA_X =
		coeff_s_XY * negative_inverse_square_DELTA(aX, bX, nX);
	const long double coeff_DELTA_Y =
		coeff_s_XY * negative_inverse_square_DELTA(aY, bY, nY);

	long double maxnorm_iterdiff = INFINITY;
	unsigned long long itercount = 0;
	unsigned long long aiX, aiY, biX, biY;

	long double * T = *T_arg;
	long double * T2 = *T2_arg;
	long double * T3;

	/* ------ End of variable declarations; start of procedures. ------ */

	if (point_gridcoord_block_from_proc_coord(mX, wX, nX, 1, &aiX, &biX))
		return 2;
	if (point_gridcoord_block_from_proc_coord(mY, wY, nY, 1, &aiY, &biY))
		return 2;

	/* Do Jacobi. */
	if (prog_stream) fprintf(prog_stream,
		"%s\t%s\n",
		"maxnorm_iterdiff",
		"itercount");
	while (maxnorm_iterdiff > max_maxnorm_iterdiff) {
		maxnorm_iterdiff = 0;
		for (unsigned long long iY = aiY+1; iY <= biY-1; ++iY) {
			for (unsigned long long iX = aiX+1; iX <= biX-1; ++iX) {
				unsigned long long const j = j_from_iXY(iX, nX, iY);
				long double const t_new =
					coeff_s_XY * S[j] +
					coeff_DELTA_Y * T[j - nX] +
					coeff_DELTA_X * T[j - 1] +
					coeff_DELTA_X * T[j + 1] +
					coeff_DELTA_Y * T[j + nX];
				long double const normterm_iterdiff = fabsl(t_new - T[j]);
				if (normterm_iterdiff > maxnorm_iterdiff) {
					maxnorm_iterdiff = normterm_iterdiff;
				}
				T2[j] = t_new;
			}
		}
		leonpthread_allreduce_max_long_double(
			&maxnorm_iterdiff,
			allreduce_mutex,
			allreduce_barrier);
		T3 = T;
		T = T2;
		T2 = T3;
		++itercount;
		if (prog_stream) fprintf(prog_stream,
			"%.*Le\t%llu\n",
			DECIMAL_DIG, maxnorm_iterdiff,
			itercount);
	}
	if (!(wX*wY)) {
		*T_arg = T;
		*T2_arg = T2;
	}

	return 0;
}

struct project_iter_bundle {
	long double const * S;
	long double * * T;
	long double * * T2;
	long double aX;
	long double aY;
	long double bX;
	long double bY;
	unsigned long long nX;
	unsigned long long nY;
	unsigned long long mX;
	unsigned long long mY;
	unsigned long long wX;
	unsigned long long wY;
	long double max_maxnorm_iterdiff;
	FILE * prog_stream;
	pthread_mutex_t * allreduce_mutex;
	pthread_barrier_t * allreduce_barrier;
};

void * project_iter_run(
	void * argument)
{
	struct project_iter_bundle const * const bundle =
		(struct project_iter_bundle const *) argument;
	project_iter(
		bundle->S,
		bundle->T,
		bundle->T2,
		bundle->aX,
		bundle->aY,
		bundle->bX,
		bundle->bY,
		bundle->nX,
		bundle->nY,
		bundle->mX,
		bundle->mY,
		bundle->wX,
		bundle->wY,
		bundle->max_maxnorm_iterdiff,
		bundle->prog_stream,
		bundle->allreduce_mutex,
		bundle->allreduce_barrier);
	return NULL;
}

/**
 * Prints final results.
 */
int project_print_vtk(
	long double const * const T,
	long double const aX,
	long double const aY,
	long double const bX,
	long double const bY,
	unsigned long long const nX,
	unsigned long long const nY,
	FILE * const vtk_stream,
	char const * const vtk_title,
	char const * const vtk_dataName)
{
	print_vtk_1(vtk_stream, vtk_title, nX, nY);
	print_vtk_2(vtk_stream, aX, aY, bX, bY, nX, nY);
	print_vtk_3(vtk_stream, vtk_dataName, nX, nY);
	print_vtk_4(vtk_stream, nX, nY, T);
	return 0;
}

int project_print_err(
	long double const * const T,
	long double (* const answer_function)(
		long double const x,
		long double const y),
	long double const aX,
	long double const aY,
	long double const bX,
	long double const bY,
	unsigned long long const nX,
	unsigned long long const nY,
	unsigned long long const mX,
	unsigned long long const mY,
	unsigned long long const wX,
	unsigned long long const wY,
	FILE * const err_stream,
	pthread_mutex_t * const allreduce_mutex,
	pthread_barrier_t * const allreduce_barrier)
{
	long double maxnorm_err = -INFINITY;
	unsigned long long aiX, aiY, biX, biY;

	/* ------ End of variable declarations; start of procedures. ------ */

	if (point_gridcoord_block_from_proc_coord(mX, wX, nX, 1, &aiX, &biX))
		return 2;
	if (point_gridcoord_block_from_proc_coord(mY, wY, nY, 1, &aiY, &biY))
		return 2;

	for (unsigned long long iY = aiY+1; iY <= biY-1; ++iY) {
		for (unsigned long long iX = aiX+1; iX <= biX-1; ++iX) {
			unsigned long long const j = j_from_iXY(iX, nX, iY);
			long double const normterm_err = fabsl(T[j] - answer_function(
				x_from_i(iX, aX, bX, nX),
				x_from_i(iY, aY, bY, nY)));
			if (normterm_err > maxnorm_err) {
				maxnorm_err = normterm_err;
			}
		}
	}
	leonpthread_allreduce_max_long_double(
		&maxnorm_err,
		allreduce_mutex,
		allreduce_barrier);
	if (err_stream) fprintf(err_stream,
		"%Lg\t%Lg\t%Lg\t%Lg\t%llu\t%llu\t%.*Le\n",
		aX, aY, bX, bY, nX, nY,
		DECIMAL_DIG, maxnorm_err);

	return 0;
}

struct project_print_err_bundle {
	long double const * T;
	long double (* answer_function)(
		long double const x,
		long double const y);
	long double aX;
	long double aY;
	long double bX;
	long double bY;
	unsigned long long nX;
	unsigned long long nY;
	unsigned long long mX;
	unsigned long long mY;
	unsigned long long wX;
	unsigned long long wY;
	FILE * err_stream;
	pthread_mutex_t * allreduce_mutex;
	pthread_barrier_t * allreduce_barrier;
};

void * project_print_err_run(
	void * argument)
{
	struct project_print_err_bundle const * const bundle =
		(struct project_print_err_bundle const *) argument;
	project_print_err(
		bundle->T,
		bundle->answer_function,
		bundle->aX,
		bundle->aY,
		bundle->bX,
		bundle->bY,
		bundle->nX,
		bundle->nY,
		bundle->mX,
		bundle->mY,
		bundle->wX,
		bundle->wY,
		bundle->err_stream,
		bundle->allreduce_mutex,
		bundle->allreduce_barrier);
	return NULL;
}

int project_destroy(
	long double * const S,
	long double * const T,
	long double * const T2)
{
	free(S);
	free(T);
	free(T2);
	return 0;
}

int main(
	int const argc,
	char * const argv[])
{

	/* Algorithm parameters. */
	long double (*source_function)(
		long double const x,
		long double const y);
	long double (*boundary_value_function)(
		long double const x,
		long double const y);
	long double aX;
	long double aY;
	long double bX;
	long double bY;
	unsigned long long nX;
	unsigned long long nY;
	unsigned long long mX;
	unsigned long long mY;
	long double max_maxnorm_iterdiff;

	/* Variables for report generation. */
	long double (*answer_function)(
		long double const x,
		long double const y);
	char * vtk_stream_pathname;
	char * vtk_title;
	char * vtk_dataName;
	char * prog_stream_pathname;
	char * err_stream_pathname;
	char * time_stream_pathname;
	FILE * vtk_stream = NULL;
	FILE * prog_stream = NULL;
	FILE * err_stream = NULL;
	FILE * time_stream = NULL;

	/* The column vectors in the matrix equation. */
	long double * S;
	long double * T;
	long double * T2;

	/* Parallel stuff */
	pthread_t * threads;
	struct project_init_1_bundle * project_init_1_bundles;
	struct project_iter_bundle * project_iter_bundles;
	struct project_print_err_bundle * project_print_err_bundles;
	pthread_mutex_t allreduce_mutex;
	pthread_barrier_t allreduce_barrier;
	unsigned long long wX;
	unsigned long long wY;
	unsigned long long j;

	/* Variables for timing. */
	struct timeval time1;
	struct timeval time2;

	/* Return value. */
	int rv = 0;

	/* ------ End of variable declarations; start of procedures. ------ */

	gettimeofday(&time1, NULL);
	if (argc < 19) return 2;
	source_function                = strtoull(argv[ 1], NULL, 10) ? source1 : source2;
	boundary_value_function        = strtoull(argv[ 2], NULL, 10) ? boundary_value1 : boundary_value2;
	answer_function                = strtoull(argv[ 3], NULL, 10) ? Tans_verification : NULL;
	aX                             = strtold (argv[ 4], NULL);
	aY                             = strtold (argv[ 5], NULL);
	bX                             = strtold (argv[ 6], NULL);
	bY                             = strtold (argv[ 7], NULL);
	nX                             = strtoull(argv[ 8], NULL, 10);
	nY                             = strtoull(argv[ 9], NULL, 10);
	mX                             = strtoull(argv[10], NULL, 10);
	mY                             = strtoull(argv[11], NULL, 10);
	max_maxnorm_iterdiff           = strtold (argv[12], NULL);
	vtk_stream_pathname            =          argv[13];
	vtk_title                      =          argv[14];
	vtk_dataName                   =          argv[15];
	prog_stream_pathname           =          argv[16];
	err_stream_pathname            =          argv[17];
	time_stream_pathname           =          argv[18];

	if (vtk_stream_pathname[0])
		setbuf(vtk_stream = fopen(vtk_stream_pathname, "w"), NULL);
	if (prog_stream_pathname[0])
		setbuf(prog_stream = fopen(prog_stream_pathname, "w"), NULL);
	if (err_stream_pathname[0])
		setbuf(err_stream = fopen(err_stream_pathname, "w"), NULL);
	if (time_stream_pathname[0])
		setbuf(time_stream = fopen(time_stream_pathname, "w"), NULL);

	threads = malloc(l_from_nXY(mX, mY) * sizeof *threads);
	project_init_1_bundles = malloc(l_from_nXY(mX, mY) * sizeof *project_init_1_bundles);
	project_iter_bundles = malloc(l_from_nXY(mX, mY) * sizeof *project_iter_bundles);
	project_print_err_bundles = malloc(l_from_nXY(mX, mY) * sizeof *project_print_err_bundles);
	pthread_mutex_init(&allreduce_mutex, NULL);
	pthread_barrier_init(&allreduce_barrier, NULL, l_from_nXY(mX, mY));

	project_init_0(nX, nY, &S, &T, &T2);
	for (wX = 0; wX < mX; ++wX) {
		for (wY = 0; wY < mY; ++wY) {
			j = j_from_iXY(wX, mX, wY);
			project_init_1_bundles[j] = (struct project_init_1_bundle) {
				.source_function = source_function,
				.boundary_value_function = boundary_value_function,
				.aX = aX,
				.aY = aY,
				.bX = bX,
				.bY = bY,
				.nX = nX,
				.nY = nY,
				.mX = mX,
				.mY = mY,
				.wX = wX,
				.wY = wY,
				.S = S,
				.T = T,
				.T2 = T2,
			};
			pthread_create(
				&threads[j],
				NULL,
				project_init_1_run,
				(void *) & project_init_1_bundles[j]);
		}
	}
	for (wX = 0; wX < mX; ++wX)
		for (wY = 0; wY < mY; ++wY)
			pthread_join(threads[j_from_iXY(wX, mX, wY)], NULL);
	for (wX = 0; wX < mX; ++wX) {
		for (wY = 0; wY < mY; ++wY) {
			j = j_from_iXY(wX, mX, wY);
			project_iter_bundles[j] = (struct project_iter_bundle) {
				.S = S,
				.T = &T,
				.T2 = &T2,
				.aX = aX,
				.aY = aY,
				.bX = bX,
				.bY = bY,
				.nX = nX,
				.nY = nY,
				.mX = mX,
				.mY = mY,
				.wX = wX,
				.wY = wY,
				.max_maxnorm_iterdiff = max_maxnorm_iterdiff,
				.prog_stream = j ? NULL : prog_stream,
				.allreduce_mutex = &allreduce_mutex,
				.allreduce_barrier = &allreduce_barrier,
			};
			pthread_create(
				&threads[j],
				NULL,
				project_iter_run,
				(void *) & project_iter_bundles[j]);
		}
	}
	for (wX = 0; wX < mX; ++wX)
		for (wY = 0; wY < mY; ++wY)
			pthread_join(threads[j_from_iXY(wX, mX, wY)], NULL);
	project_print_vtk(T, aX, aY, bX, bY, nX, nY,
		vtk_stream, vtk_title, vtk_dataName);
	for (wX = 0; wX < mX; ++wX) {
		for (wY = 0; wY < mY; ++wY) {
			j = j_from_iXY(wX, mX, wY);
			project_print_err_bundles[j] = (struct project_print_err_bundle) {
				.T = T,
				.answer_function = answer_function,
				.aX = aX,
				.aY = aY,
				.bX = bX,
				.bY = bY,
				.nX = nX,
				.nY = nY,
				.mX = mX,
				.mY = mY,
				.wX = wX,
				.wY = wY,
				.err_stream = j ? NULL : err_stream,
				.allreduce_mutex = &allreduce_mutex,
				.allreduce_barrier = &allreduce_barrier,
			};
			pthread_create(
				&threads[j],
				NULL,
				project_print_err_run,
				(void *) & project_print_err_bundles[j]);
		}
	}
	for (wX = 0; wX < mX; ++wX)
		for (wY = 0; wY < mY; ++wY)
			pthread_join(threads[j_from_iXY(wX, mX, wY)], NULL);
	project_destroy(S, T, T2);

	pthread_mutex_destroy(&allreduce_mutex);
	pthread_barrier_destroy(&allreduce_barrier);

	if (vtk_stream)
		fclose(vtk_stream);
	if (prog_stream)
		fclose(prog_stream);
	if (err_stream)
		fclose(err_stream);
	if (time_stream) {
		gettimeofday(&time2, NULL);
		fprintf(time_stream,
			"%f\n",
			(double)(time2.tv_usec - time1.tv_usec) / 1.0e+6 +
			time2.tv_sec - time1.tv_sec);
		fclose(time_stream);
	}

	return rv;
}
