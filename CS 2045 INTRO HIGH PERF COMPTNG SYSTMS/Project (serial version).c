/* ------------------------------------------------------------------------ *\
	CLASS   :  2191 CS 2045 SEC1020 INTRO HIGH PERF COMPTNG SYSTMS
	AUTHOR  :  Leon Lai <Leon.Lai@pitt.edu>
	TITLE   :  2-D Poisson's equation solver
	DATE    :  2018-11-01
\* ------------------------------------------------------------------------ */

#include <float.h>        /* DECIMAL_DIG */
#include <math.h>         /* expl fabsl INFINITY */
#include <stdio.h>        /* fclose fopen fprintf NULL printf setbuf stderr stdout */
#include <stdlib.h>       /* strtold strtoull */
#include <sys/time.h>     /* [POSIX not ISO] gettimeofday timeval */

static long double DELTA(
	const long double a,
	const long double b,
	const unsigned long long n)
{
	return (b - a) / (n - 1);
}

static long double negative_inverse_square_DELTA(
	const long double a,
	const long double b,
	const unsigned long long n)
{
	return -1.0L / (DELTA(a, b, n) * DELTA(a, b, n));
}

static long double x_from_i(
	const unsigned long long i,
	const long double a,
	const long double b,
	const unsigned long long n)
{
	return a + i * DELTA(a, b, n);
}

static unsigned long long l_from_nXY(
	const unsigned long long nX,
	const unsigned long long nY)
{
	return nX * nY;
}

static unsigned long long j_from_iXY(
	const unsigned long long iX,
	const unsigned long long nX,
	const unsigned long long iY)
{
	/* Cf. iX + nX * iY + nX * nY * iZ */
	return iX + nX * iY;
}

int print_vtk_1(
	FILE *stream,
	const char *title,
	const unsigned long long nX,
	const unsigned long long nY)
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
	FILE *stream,
	const long double aX,
	const long double aY,
	const long double bX,
	const long double bY,
	const unsigned long long nX,
	const unsigned long long nY)
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
	FILE *stream,
	const char *dataName,
	const unsigned long long nX,
	const unsigned long long nY)
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
	FILE *stream,
	const unsigned long long nX,
	const unsigned long long nY,
	const long double *vector)
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

int do_project1(
	long double (*source_function)(
		const long double x,
		const long double y),
	long double (*boundary_value_function)(
		const long double x,
		const long double y),
	long double (*answer_function)(
		const long double x,
		const long double y),
	const long double aX,
	const long double aY,
	const long double bX,
	const long double bY,
	const unsigned long long nX,
	const unsigned long long nY,
	const long double max_maxnorm_iterdiff,     /* negative to disable */
	const unsigned short do_jacobi_not_gaussseidel,
	FILE *vtk_stream,                           /* NULL to disable */
	const char *vtk_title,
	const char *vtk_dataName,
	FILE *time_stream,                          /* NULL to disable */
	FILE *prog_stream,                          /* NULL to disable */
	FILE *err_stream)                           /* NULL to disable */
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

	/* The column vectors in the matrix equation. */
	long double *S;
	long double *T;
	long double *T2;
	long double *T3;

	/* Variables for use in iterations. */
	unsigned long long iX, iY, j;
	long double maxnorm_iterdiff;
	long double normterm_iterdiff;
	unsigned long long itercount;
	long double t_new;

	/* Variables for timing. */
	struct timeval time1, time2;

	/* Variables for error. */
	long double maxnorm_err;
	long double normterm_err;

	/* Return value. */
	int rv = 0;

	/* ------ End of variable declarations; start of procedures. ------ */

	if (!(S = malloc(l_from_nXY(nX, nY) * sizeof *S)))
		return 2;
	if (!(T = malloc(l_from_nXY(nX, nY) * sizeof *T)))
		return 2;
	if (do_jacobi_not_gaussseidel)
		if (!(T2 = malloc(l_from_nXY(nX, nY) * sizeof *T2)))
			return 2;

	/* Set the source, boundary, and if known, exact solution values. */
	gettimeofday(&time1, NULL);
	for (iY = 0; iY <= nY-1; ++iY) {
		for (iX = 0; iX <= nX-1; ++iX) {
			j = j_from_iXY(iX, nX, iY);
			S[j] = source_function(
				x_from_i(iX, aX, bX, nX),
				x_from_i(iY, aY, bY, nY));
			if (iX == 0 ||
				iX == nX - 1 ||
				iY == 0 ||
				iY == nY - 1) {
				T[j] = boundary_value_function(
					x_from_i(iX, aX, bX, nX),
					x_from_i(iY, aY, bY, nY));
			} else {
				T[j] = 0;
			}
			if (do_jacobi_not_gaussseidel)
				T2[j] = T[j];
		}
	}
	gettimeofday(&time2, NULL);
	if (time_stream) fprintf(time_stream,
		"%f\t",
		(double)(time2.tv_usec - time1.tv_usec) / 1.0e+6 +
		time2.tv_sec - time1.tv_sec);

	/* Do Jacobi or Gauss-Seidel. */
	if (prog_stream) fprintf(prog_stream,
		"%s\t%s\n",
		"maxnorm_iterdiff",
		"itercount");
	gettimeofday(&time1, NULL);
	for (maxnorm_iterdiff = INFINITY,
		itercount = 0;
		!(
			(max_maxnorm_iterdiff >= 0 &&
				maxnorm_iterdiff <= max_maxnorm_iterdiff)
		);
		++itercount) {
		if (prog_stream) fprintf(prog_stream,
			"%.*Le\t%llu\n",
			DECIMAL_DIG, maxnorm_iterdiff,
			itercount);
		maxnorm_iterdiff = 0.0L;
		for (iY = 1; iY <= nY-2; ++iY) {
			for (iX = 1; iX <= nX-2; ++iX) {
				j = j_from_iXY(iX, nX, iY);
				t_new =
				coeff_s_XY * S[j] +
				coeff_DELTA_Y * T[j - nX] +
				coeff_DELTA_X * T[j - 1] +
				coeff_DELTA_X * T[j + 1] +
				coeff_DELTA_Y * T[j + nX];
				normterm_iterdiff = fabsl(t_new - T[j]);
				if (normterm_iterdiff > maxnorm_iterdiff) {
					maxnorm_iterdiff = normterm_iterdiff;
				}
				if (do_jacobi_not_gaussseidel) {
					T2[j] = t_new;
				} else {
					T[j] = t_new;
				}
			}
		}
		if (do_jacobi_not_gaussseidel) {
			T3 = T;
			T = T2;
			T2 = T3;
		}
	}
	gettimeofday(&time2, NULL);
	if (prog_stream) fprintf(prog_stream,
		"%.*Le\t%llu\n",
		DECIMAL_DIG, maxnorm_iterdiff,
		itercount);
	if (time_stream) fprintf(time_stream,
		"%f\t",
		(double)(time2.tv_usec - time1.tv_usec) / 1.0e+6 +
		time2.tv_sec - time1.tv_sec);

	/* Print final results. */
	gettimeofday(&time1, NULL);
	if (vtk_stream) {
		print_vtk_1(vtk_stream, vtk_title, nX, nY);
		print_vtk_2(vtk_stream, aX, aY, bX, bY, nX, nY);
		print_vtk_3(vtk_stream, vtk_dataName, nX, nY);
		print_vtk_4(vtk_stream, nX, nY, T);
	}
	if (answer_function) {
		maxnorm_err = 0.0L;
		for (iY = 1; iY <= nY-2; ++iY) {
			for (iX = 1; iX <= nX-2; ++iX) {
				j = j_from_iXY(iX, nX, iY);
				normterm_err = fabsl(T[j] - answer_function(
					x_from_i(iX, aX, bX, nX),
					x_from_i(iY, aY, bY, nY)));
				if (normterm_err > maxnorm_err) {
					maxnorm_err = normterm_err;
				}
			}
		}
		if (err_stream) fprintf(err_stream,
			"%Lg\t%Lg\t%Lg\t%Lg\t%llu\t%llu\t%.*Le\n",
			aX, aY, bX, bY, nX, nY,
			DECIMAL_DIG, maxnorm_err);
	}
	gettimeofday(&time2, NULL);
	if (time_stream) fprintf(time_stream,
		"%f\t",
		(double)(time2.tv_usec - time1.tv_usec) / 1.0e+6 +
		time2.tv_sec - time1.tv_sec);

	free(S);
	free(T);
	if (do_jacobi_not_gaussseidel)
		free(T2);
	return rv;
}

static long double Tans_verification(
	const long double x,
	const long double y)
{
	return x * expl(y);
}

static long double source1(
	const long double x,
	const long double y)
{
	return x * expl(y);
}

static long double source2()
{
	return 0.2;
}

static long double boundary_value1(
	const long double x,
	const long double y)
{
	return x * expl(y);
}

static long double boundary_value2()
{
	return 0;
}

int main(
	int argc,
	char *argv[])
{
	FILE *vtk_stream = NULL;
	FILE *time_stream = NULL;
	FILE *prog_stream = NULL;
	FILE *err_stream = NULL;

	/* Variables for timing. */
	struct timeval time1, time2;

	/* Return value. */
	int rv = 0;

	/* ------ End of variable declarations; start of procedures. ------ */

	gettimeofday(&time1, NULL);
	if (argc < 16) return 2;
	if (argv[12][0] != '\0') vtk_stream = fopen(argv[12], "w");
	if (argv[15][0] != '\0') time_stream = fopen(argv[15], "w");
	if (argv[16][0] != '\0') prog_stream = fopen(argv[16], "w");
	if (argv[17][0] != '\0') err_stream = fopen(argv[17], "w");
	if (vtk_stream) setbuf(vtk_stream, NULL);
	if (time_stream) setbuf(time_stream, NULL);
	if (prog_stream) setbuf(prog_stream, NULL);
	if (err_stream) setbuf(err_stream, NULL);
	rv = do_project1(
		strtoull(argv[1], NULL, 10) ? source1 : source2,
		strtoull(argv[2], NULL, 10) ? boundary_value1 : boundary_value2,
		strtoull(argv[3], NULL, 10) ? Tans_verification : NULL,
		strtold(argv[4], NULL),
		strtold(argv[5], NULL),
		strtold(argv[6], NULL),
		strtold(argv[7], NULL),
		strtoull(argv[8], NULL, 10),
		strtoull(argv[9], NULL, 10),
		strtold(argv[10], NULL),
		(unsigned short) strtoull(argv[11], NULL, 10),
		vtk_stream,
		argv[13],
		argv[14],
		time_stream,
		prog_stream,
		err_stream);
	if (vtk_stream) fclose(vtk_stream);
	if (prog_stream) fclose(prog_stream);
	if (err_stream) fclose(err_stream);
	gettimeofday(&time2, NULL);
	if (time_stream) fprintf(time_stream,
		"%f\n",
		(double)(time2.tv_usec - time1.tv_usec) / 1.0e+6 +
		time2.tv_sec - time1.tv_sec);
	if (time_stream) fclose(time_stream);
	return rv;
}
