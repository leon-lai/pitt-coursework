/* ------------------------------------------------------------------------ *\
	CLASS   :  2191 CS 2045 SEC1020 INTRO HIGH PERF COMPTNG SYSTMS
	AUTHOR  :  Leon Lai <Leon.Lai@pitt.edu>
	TITLE   :  2-D Poisson's equation solver (OpenMP version)
	DATE    :  2018-12-08
\* ------------------------------------------------------------------------ */

#include <float.h>        /* DECIMAL_DIG */
#include <math.h>         /* exp fabs fmax INFINITY */
#include <stdio.h>        /* fclose fopen fprintf NULL printf setbuf stderr stdout */
#include <stdlib.h>       /* strtold strtoull */
#include <sys/time.h>     /* [POSIX not ISO] gettimeofday timeval */
#include <omp.h>

static double source_function(
	double const x,
	double const y)
{
	return x * exp(y);
}

static double boundary_value_function(
	double const x,
	double const y)
{
	return x * exp(y);
}

static double answer_function(
	double const x,
	double const y)
{
	return x * exp(y);
}

static double DELTA(
	double const a,
	double const b,
	unsigned long long const n)
{
	return (b - a) / (n - 1);
}

static double negative_inverse_square_DELTA(
	double const a,
	double const b,
	unsigned long long const n)
{
	return -1.0 / (DELTA(a, b, n) * DELTA(a, b, n));
}

static double x_from_i(
	unsigned long long const i,
	double const a,
	double const b,
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
	double const aX,
	double const aY,
	double const bX,
	double const bY,
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
			rv += fprintf(stream, "%f %f %f\n",
				x_from_i(iX, aX, bX, nX),
				x_from_i(iY, aY, bY, nY),
				0.0);
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
	double const * const vector)
{
	/* Variables for use in iterations. */
	unsigned long long iX, iY;

	/* Return value. */
	int rv = 0;

	/* ------ End of variable declarations; start of procedures. ------ */

	for (iY = 0; iY <= nY-1; ++iY) {
		for (iX = 0; iX <= nX-1; ++iX) {
			rv += fprintf(stream, "%f\n",
				vector[j_from_iXY(iX, nX, iY)]);
		}
	}
	return rv;
}

int project_init_0(
	unsigned long long const nX,
	unsigned long long const nY,
	double * * const S,
	double * * const T,
	double * * const T2)
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
	double const aX,
	double const aY,
	double const bX,
	double const bY,
	unsigned long long const nX,
	unsigned long long const nY,
	double * const S,
	double * const T,
	double * const T2)
{
	unsigned long long aiX=0, aiY=0, biX=nX-1, biY=nY-1;

	/* ------ End of variable declarations; start of procedures. ------ */

	#pragma omp parallel for collapse(2)
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

int project_iter(
	double const * const S,
	double * * const T_arg,
	double * * const T2_arg,
	double const aX,
	double const aY,
	double const bX,
	double const bY,
	unsigned long long const nX,
	unsigned long long const nY,
	double const max_maxnorm_iterdiff,
	FILE * const prog_stream)
{
	/* Coefficients for Jacobi/Gauss-Seidel 2D PE solving. */
	const double coeff_s_XY = (1.0 / 2.0) / (
		negative_inverse_square_DELTA(aX, bX, nX)
		+
		negative_inverse_square_DELTA(aY, bY, nY)
	);
	const double coeff_DELTA_X =
		coeff_s_XY * negative_inverse_square_DELTA(aX, bX, nX);
	const double coeff_DELTA_Y =
		coeff_s_XY * negative_inverse_square_DELTA(aY, bY, nY);

	double maxnorm_iterdiff = 1.0 / 0.0;
	unsigned long long itercount = 0;
	unsigned long long aiX=0, aiY=0, biX=nX-1, biY=nY-1;

	double * T = *T_arg;
	double * T2 = *T2_arg;
	double * T3;

	/* ------ End of variable declarations; start of procedures. ------ */

	/* Do Jacobi. */
	if (prog_stream) fprintf(prog_stream,
		"%s\t%s\n",
		"maxnorm_iterdiff",
		"itercount");
	while (maxnorm_iterdiff > max_maxnorm_iterdiff) {
		maxnorm_iterdiff = 0;
		#pragma omp parallel for collapse(2) reduction(max : maxnorm_iterdiff)
		for (unsigned long long iY = aiY+1; iY <= biY-1; ++iY) {
			for (unsigned long long iX = aiX+1; iX <= biX-1; ++iX) {
				unsigned long long const j = j_from_iXY(iX, nX, iY);
				double const t_new =
					coeff_s_XY * S[j] +
					coeff_DELTA_Y * T[j - nX] +
					coeff_DELTA_X * T[j - 1] +
					coeff_DELTA_X * T[j + 1] +
					coeff_DELTA_Y * T[j + nX];
				maxnorm_iterdiff = fmax(
					maxnorm_iterdiff,
					fabs(t_new - T[j]));
				T2[j] = t_new;
			}
		}
		/* maxnorm_iterdiff */
		T3 = T;
		T = T2;
		T2 = T3;
		++itercount;
		if (prog_stream) fprintf(prog_stream,
			"%.*e\t%llu\n",
			DECIMAL_DIG, maxnorm_iterdiff,
			itercount);
	}
	*T_arg = T;
	*T2_arg = T2;

	return 0;
}

/**
 * Prints final results.
 */
int project_print_vtk(
	double const * const T,
	double const aX,
	double const aY,
	double const bX,
	double const bY,
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
	double const * const T,
	double const aX,
	double const aY,
	double const bX,
	double const bY,
	unsigned long long const nX,
	unsigned long long const nY,
	FILE * const err_stream)
{
	double maxnorm_err = -1;
	unsigned long long aiX=0, aiY=0, biX=nX-1, biY=nY-1;

	/* ------ End of variable declarations; start of procedures. ------ */

	#pragma omp parallel for collapse(2) reduction(max : maxnorm_err)
	for (unsigned long long iY = aiY+1; iY <= biY-1; ++iY) {
		for (unsigned long long iX = aiX+1; iX <= biX-1; ++iX) {
			unsigned long long const j = j_from_iXY(iX, nX, iY);
			maxnorm_err = fmax(
				maxnorm_err,
				fabs(T[j] - answer_function(
					x_from_i(iX, aX, bX, nX),
					x_from_i(iY, aY, bY, nY))));
		}
	}
	/* maxnorm_iterdiff */
	if (err_stream) fprintf(err_stream,
		"%g\t%g\t%g\t%g\t%llu\t%llu\t%.*e\n",
		aX, aY, bX, bY, nX, nY,
		DECIMAL_DIG, maxnorm_err);

	return 0;
}

int project_destroy(
	double * const S,
	double * const T,
	double * const T2)
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
	double aX;
	double aY;
	double bX;
	double bY;
	unsigned long long nX;
	unsigned long long nY;
	double max_maxnorm_iterdiff;

	/* Variables for report generation. */
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
	double * S;
	double * T;
	double * T2;

	/* Variables for timing. */
	struct timeval time1;
	struct timeval time2;

	/* Return value. */
	int rv = 0;

	/* ------ End of variable declarations; start of procedures. ------ */

	gettimeofday(&time1, NULL);
	if (argc < 14) return 2;
	aX                             = strtold (argv[ 1], NULL);
	aY                             = strtold (argv[ 2], NULL);
	bX                             = strtold (argv[ 3], NULL);
	bY                             = strtold (argv[ 4], NULL);
	nX                             = strtoull(argv[ 5], NULL, 10);
	nY                             = strtoull(argv[ 6], NULL, 10);
	max_maxnorm_iterdiff           = strtold (argv[ 7], NULL);
	vtk_stream_pathname            =          argv[ 8];
	vtk_title                      =          argv[ 9];
	vtk_dataName                   =          argv[10];
	prog_stream_pathname           =          argv[11];
	err_stream_pathname            =          argv[12];
	time_stream_pathname           =          argv[13];

	if (vtk_stream_pathname[0])
		setbuf(vtk_stream = fopen(vtk_stream_pathname, "w"), NULL);
	if (prog_stream_pathname[0])
		setbuf(prog_stream = fopen(prog_stream_pathname, "w"), NULL);
	if (err_stream_pathname[0])
		setbuf(err_stream = fopen(err_stream_pathname, "w"), NULL);
	if (time_stream_pathname[0])
		setbuf(time_stream = fopen(time_stream_pathname, "w"), NULL);

	project_init_0(nX, nY, &S, &T, &T2);

	project_init_1(
		aX,
		aY,
		bX,
		bY,
		nX,
		nY,
		S,
		T,
		T2);

	project_iter(
		S,
		&T,
		&T2,
		aX,
		aY,
		bX,
		bY,
		nX,
		nY,
		max_maxnorm_iterdiff,
		prog_stream);

	if (vtk_stream)
		project_print_vtk(T, aX, aY, bX, bY, nX, nY,
			vtk_stream, vtk_title, vtk_dataName);

	project_print_err(
		T,
		aX,
		aY,
		bX,
		bY,
		nX,
		nY,
		err_stream);

	project_destroy(S, T, T2);

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
