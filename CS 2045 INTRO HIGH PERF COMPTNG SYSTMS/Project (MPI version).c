/* ------------------------------------------------------------------------ *\
	CLASS   :  2191 CS 2045 SEC1020 INTRO HIGH PERF COMPTNG SYSTMS
	AUTHOR  :  Leon Lai <Leon.Lai@pitt.edu>
	TITLE   :  2-D Poisson's equation solver (MPI version)
	DATE    :  2018-11-01
\* ------------------------------------------------------------------------ */

#include <float.h>        /* DECIMAL_DIG */
#include <math.h>         /* expl fabsl INFINITY */
#include <stdio.h>        /* fclose fopen fprintf NULL printf setbuf snprintf stderr stdout */
#include <stdlib.h>       /* strtold strtoull */
#include <mpi.h>

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
	const unsigned long long nY,
	const unsigned long long aiX_print,
	const unsigned long long aiY_print,
	const unsigned long long biX_print,
	const unsigned long long biY_print)
{
	/* Variables for use in iterations. */
	unsigned long long iX, iY;

	/* Return value. */
	int rv = 0;

	/* ------ End of variable declarations; start of procedures. ------ */

	for (iY = aiY_print; iY <= biY_print; ++iY) {
		for (iX = aiX_print; iX <= biX_print; ++iX) {
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
	const unsigned long long aiX_vector,
	const unsigned long long aiY_vector,
	const unsigned long long biX_vector,
	const unsigned long long biY_vector,
	const unsigned long long aiX_print,
	const unsigned long long aiY_print,
	const unsigned long long biX_print,
	const unsigned long long biY_print,
	const long double *vector)
{
	const unsigned long long niX_vector = biX_vector + 1 - aiX_vector;
	const unsigned long long niY_vector = biY_vector + 1 - aiY_vector;

	/* Variables for use in iterations. */
	unsigned long long iX, iY;

	/* Return value. */
	int rv = 0;

	/* ------ End of variable declarations; start of procedures. ------ */

	for (iY = aiY_print; iY <= biY_print; ++iY) {
		for (iX = aiX_print; iX <= biX_print; ++iX) {
			rv += fprintf(stream, "%Lf\n",
				vector[j_from_iXY(
					iX-aiX_vector,
					niX_vector,
					iY-aiY_vector)]);
		}
	}
	return rv;
}

int do_project2(
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
	const MPI_Comm comm_cart,
	const unsigned long long aiX,
	const unsigned long long aiY,
	const unsigned long long biX,
	const unsigned long long biY,
	const int proc_DELTA_X_a,
	const int proc_DELTA_X_b,
	const int proc_DELTA_Y_a,
	const int proc_DELTA_Y_b,
	const long double max_maxnorm_iterdiff,     /* negative to disable */
	const unsigned short do_jacobi_not_gaussseidel,
	FILE *vtk_1_stream,                         /* NULL to disable */
	FILE *vtk_2_stream,                         /* NULL to disable */
	FILE *vtk_3_stream,                         /* NULL to disable */
	FILE *vtk_4_stream,                         /* NULL to disable */
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
	double time1, time2;

	/* Variables for error. */
	long double maxnorm_err;
	long double normterm_err;

	/* MPI. */
	const unsigned long long niX = biX + 1 - aiX;
	const unsigned long long niY = biY + 1 - aiY;
	long double *proc_DELTA_X_a_border_sendbuf;
	/*long double proc_DELTA_X_a_corner_a_sendbuf;*/
	/*long double proc_DELTA_X_a_corner_b_sendbuf;*/
	long double *proc_DELTA_X_b_border_sendbuf;
	/*long double proc_DELTA_X_b_corner_a_sendbuf;*/
	/*long double proc_DELTA_X_b_corner_b_sendbuf;*/
	long double *proc_DELTA_Y_a_border_sendbuf;
	/*long double proc_DELTA_Y_a_corner_a_sendbuf;*/
	/*long double proc_DELTA_Y_a_corner_b_sendbuf;*/
	long double *proc_DELTA_Y_b_border_sendbuf;
	/*long double proc_DELTA_Y_b_corner_a_sendbuf;*/
	/*long double proc_DELTA_Y_b_corner_b_sendbuf;*/
	long double *proc_DELTA_X_a_border_recvbuf;
	/*long double proc_DELTA_X_a_corner_a_recvbuf;*/
	/*long double proc_DELTA_X_a_corner_b_recvbuf;*/
	long double *proc_DELTA_X_b_border_recvbuf;
	/*long double proc_DELTA_X_b_corner_a_recvbuf;*/
	/*long double proc_DELTA_X_b_corner_b_recvbuf;*/
	long double *proc_DELTA_Y_a_border_recvbuf;
	/*long double proc_DELTA_Y_a_corner_a_recvbuf;*/
	/*long double proc_DELTA_Y_a_corner_b_recvbuf;*/
	long double *proc_DELTA_Y_b_border_recvbuf;
	/*long double proc_DELTA_Y_b_corner_a_recvbuf;*/
	/*long double proc_DELTA_Y_b_corner_b_recvbuf;*/
	MPI_Request border_requests[4 * 2];         /* @todo no track send */
	MPI_Status border_statuses[4 * 2];          /* @todo no track send */
	/*MPI_Request corner_requests[8 * 2];          @todo no track send */
	/*MPI_Status corner_statuses[8 * 2];           @todo no track send */
	long double maxnorm_iterdiff_recvbuf;
	long double maxnorm_err_recvbuf;

	/* Return value. */
	int rv = 0;

	/* ------ End of variable declarations; start of procedures. ------ */

	if (!(S = malloc(l_from_nXY(niX, niY) * sizeof *S)))
		return 2;
	if (!(T = malloc(l_from_nXY(niX, niY) * sizeof *T)))
		return 2;
	if (do_jacobi_not_gaussseidel)
		if (!(T2 = malloc(l_from_nXY(niX, niY) * sizeof *T2)))
			return 2;
	if (!(proc_DELTA_X_a_border_sendbuf =
		malloc((niY-2) * sizeof *proc_DELTA_X_a_border_sendbuf)))
		return 2;
	if (!(proc_DELTA_X_b_border_sendbuf =
		malloc((niY-2) * sizeof *proc_DELTA_X_b_border_sendbuf)))
		return 2;
	if (!(proc_DELTA_Y_a_border_sendbuf =
		malloc((niX-2) * sizeof *proc_DELTA_Y_a_border_sendbuf)))
		return 2;
	if (!(proc_DELTA_Y_b_border_sendbuf =
		malloc((niX-2) * sizeof *proc_DELTA_Y_b_border_sendbuf)))
		return 2;
	if (!(proc_DELTA_X_a_border_recvbuf =
		malloc((niY-2) * sizeof *proc_DELTA_X_a_border_recvbuf)))
		return 2;
	if (!(proc_DELTA_X_b_border_recvbuf =
		malloc((niY-2) * sizeof *proc_DELTA_X_b_border_recvbuf)))
		return 2;
	if (!(proc_DELTA_Y_a_border_recvbuf =
		malloc((niX-2) * sizeof *proc_DELTA_Y_a_border_recvbuf)))
		return 2;
	if (!(proc_DELTA_Y_b_border_recvbuf =
		malloc((niX-2) * sizeof *proc_DELTA_Y_b_border_recvbuf)))
		return 2;
	if (proc_DELTA_X_a == MPI_PROC_NULL)
		border_requests[0] = border_requests[4] = MPI_REQUEST_NULL;
	if (proc_DELTA_X_b == MPI_PROC_NULL)
		border_requests[1] = border_requests[5] = MPI_REQUEST_NULL;
	if (proc_DELTA_Y_a == MPI_PROC_NULL)
		border_requests[2] = border_requests[6] = MPI_REQUEST_NULL;
	if (proc_DELTA_Y_b == MPI_PROC_NULL)
		border_requests[3] = border_requests[7] = MPI_REQUEST_NULL;

	/* Set the source, boundary, and if known, exact solution values. */
	time1 = MPI_Wtime();
	for (iY = aiY; iY <= biY; ++iY) {
		for (iX = aiX; iX <= biX; ++iX) {
			j = j_from_iXY(iX-aiX, niX, iY-aiY);
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
	time2 = MPI_Wtime();
	if (time_stream) fprintf(time_stream,
		"%f\t",
		time2 - time1);

	/* Do Jacobi or Gauss-Seidel. */
	if (prog_stream) fprintf(prog_stream,
		"%s\t%s\n",
		"maxnorm_iterdiff",
		"itercount");
	time1 = MPI_Wtime();
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
		for (iY = aiY+1; iY <= biY-1; ++iY) {
			for (iX = aiX+1; iX <= biX-1; ++iX) {
				j = j_from_iXY(iX-aiX, niX, iY-aiY);
				t_new =
				coeff_s_XY * S[j] +
				coeff_DELTA_Y * T[j - niX] +
				coeff_DELTA_X * T[j - 1] +
				coeff_DELTA_X * T[j + 1] +
				coeff_DELTA_Y * T[j + niX];
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
		MPI_Allreduce(
			&maxnorm_iterdiff,
			&maxnorm_iterdiff_recvbuf,
			1, MPI_LONG_DOUBLE,
			MPI_MAX, comm_cart);
		maxnorm_iterdiff = maxnorm_iterdiff_recvbuf;
		if (proc_DELTA_X_a != MPI_PROC_NULL) {
			iX = aiX+1;
			for (iY = aiY+1; iY <= biY-1; ++iY) {
				if (do_jacobi_not_gaussseidel) {
					proc_DELTA_X_a_border_sendbuf[iY-(aiY+1)] =
					T2[j_from_iXY(iX-aiX, niX, iY-aiY)];
				} else {
					proc_DELTA_X_a_border_sendbuf[iY-(aiY+1)] =
					T[j_from_iXY(iX-aiX, niX, iY-aiY)];
				}
			}
			if ((rv = MPI_Isend(
				proc_DELTA_X_a_border_sendbuf,
				niY-2, MPI_LONG_DOUBLE,
				proc_DELTA_X_a, 1, comm_cart,
				&border_requests[0])))
				return rv;
			if ((rv = MPI_Irecv(
				proc_DELTA_X_a_border_recvbuf,
				niY-2, MPI_LONG_DOUBLE,
				proc_DELTA_X_a, 1, comm_cart,
				&border_requests[4])))
				return rv;
		}
		if (proc_DELTA_X_b != MPI_PROC_NULL) {
			iX = biX-1;
			for (iY = aiY+1; iY <= biY-1; ++iY) {
				if (do_jacobi_not_gaussseidel) {
					proc_DELTA_X_b_border_sendbuf[iY-(aiY+1)] =
					T2[j_from_iXY(iX-aiX, niX, iY-aiY)];
				} else {
					proc_DELTA_X_b_border_sendbuf[iY-(aiY+1)] =
					T[j_from_iXY(iX-aiX, niX, iY-aiY)];
				}
			}
			if ((rv = MPI_Isend(
				proc_DELTA_X_b_border_sendbuf,
				niY-2, MPI_LONG_DOUBLE,
				proc_DELTA_X_b, 1, comm_cart,
				&border_requests[1])))
				return rv;
			if ((rv = MPI_Irecv(
				proc_DELTA_X_b_border_recvbuf,
				niY-2, MPI_LONG_DOUBLE,
				proc_DELTA_X_b, 1, comm_cart,
				&border_requests[5])))
				return rv;
		}
		if (proc_DELTA_Y_a != MPI_PROC_NULL) {
			iY = aiY+1;
			for (iX = aiX+1; iX <= biX-1; ++iX) {
				if (do_jacobi_not_gaussseidel) {
					proc_DELTA_Y_a_border_sendbuf[iX-(aiX+1)] =
					T2[j_from_iXY(iX-aiX, niX, iY-aiY)];
				} else {
					proc_DELTA_Y_a_border_sendbuf[iX-(aiX+1)] =
					T[j_from_iXY(iX-aiX, niX, iY-aiY)];
				}
			}
			if ((rv = MPI_Isend(
				proc_DELTA_Y_a_border_sendbuf,
				niX-2, MPI_LONG_DOUBLE,
				proc_DELTA_Y_a, 1, comm_cart,
				&border_requests[2])))
				return rv;
			if ((rv = MPI_Irecv(
				proc_DELTA_Y_a_border_recvbuf,
				niX-2, MPI_LONG_DOUBLE,
				proc_DELTA_Y_a, 1, comm_cart,
				&border_requests[6])))
				return rv;
		}
		if (proc_DELTA_Y_b != MPI_PROC_NULL) {
			iY = biY-1;
			for (iX = aiX+1; iX <= biX-1; ++iX) {
				if (do_jacobi_not_gaussseidel) {
					proc_DELTA_Y_b_border_sendbuf[iX-(aiX+1)] =
					T2[j_from_iXY(iX-aiX, niX, iY-aiY)];
				} else {
					proc_DELTA_Y_b_border_sendbuf[iX-(aiX+1)] =
					T[j_from_iXY(iX-aiX, niX, iY-aiY)];
				}
			}
			if ((rv = MPI_Isend(
				proc_DELTA_Y_b_border_sendbuf,
				niX-2, MPI_LONG_DOUBLE,
				proc_DELTA_Y_b, 1, comm_cart,
				&border_requests[3])))
				return rv;
			if ((rv = MPI_Irecv(
				proc_DELTA_Y_b_border_recvbuf,
				niX-2, MPI_LONG_DOUBLE,
				proc_DELTA_Y_b, 1, comm_cart,
				&border_requests[7])))
				return rv;
		}
		if ((rv = MPI_Waitall(8, border_requests, border_statuses)))
			return rv;
		if (proc_DELTA_X_a != MPI_PROC_NULL) {
			iX = aiX;
			for (iY = aiY+1; iY <= biY-1; ++iY) {
				if (do_jacobi_not_gaussseidel) {
					T2[j_from_iXY(iX-aiX, niX, iY-aiY)] =
					proc_DELTA_X_a_border_recvbuf[iY-(aiY+1)];
				} else {
					T[j_from_iXY(iX-aiX, niX, iY-aiY)] =
					proc_DELTA_X_a_border_recvbuf[iY-(aiY+1)];
				}
			}
		}
		if (proc_DELTA_X_b != MPI_PROC_NULL) {
			iX = biX;
			for (iY = aiY+1; iY <= biY-1; ++iY) {
				if (do_jacobi_not_gaussseidel) {
					T2[j_from_iXY(iX-aiX, niX, iY-aiY)] =
					proc_DELTA_X_b_border_recvbuf[iY-(aiY+1)];
				} else {
					T[j_from_iXY(iX-aiX, niX, iY-aiY)] =
					proc_DELTA_X_b_border_recvbuf[iY-(aiY+1)];
				}
			}
		}
		if (proc_DELTA_Y_a != MPI_PROC_NULL) {
			iY = aiY;
			for (iX = aiX+1; iX <= biX-1; ++iX) {
				if (do_jacobi_not_gaussseidel) {
					T2[j_from_iXY(iX-aiX, niX, iY-aiY)] =
					proc_DELTA_Y_a_border_recvbuf[iX-(aiX+1)];
				} else {
					T[j_from_iXY(iX-aiX, niX, iY-aiY)] =
					proc_DELTA_Y_a_border_recvbuf[iX-(aiX+1)];
				}
			}
		}
		if (proc_DELTA_Y_b != MPI_PROC_NULL) {
			iY = biY;
			for (iX = aiX+1; iX <= biX-1; ++iX) {
				if (do_jacobi_not_gaussseidel) {
					T2[j_from_iXY(iX-aiX, niX, iY-aiY)] =
					proc_DELTA_Y_b_border_recvbuf[iX-(aiX+1)];
				} else {
					T[j_from_iXY(iX-aiX, niX, iY-aiY)] =
					proc_DELTA_Y_b_border_recvbuf[iX-(aiX+1)];
				}
			}
		}
		if (do_jacobi_not_gaussseidel) {
			T3 = T;
			T = T2;
			T2 = T3;
		}
	}
	time2 = MPI_Wtime();
	if (prog_stream) fprintf(prog_stream,
		"%.*Le\t%llu\n",
		DECIMAL_DIG, maxnorm_iterdiff,
		itercount);
	if (time_stream) fprintf(time_stream,
		"%f\t",
		time2 - time1);

	/* Print final results. */
	time1 = MPI_Wtime();
	if (vtk_1_stream) {
		print_vtk_1(vtk_1_stream, vtk_title, nX, nY);
	}
	if (vtk_2_stream) {
		print_vtk_2(vtk_2_stream, aX, aY, bX, bY, nX, nY,
			aiX + ((proc_DELTA_X_a == MPI_PROC_NULL) ? 0 : 1),
			aiY + ((proc_DELTA_Y_a == MPI_PROC_NULL) ? 0 : 1),
			biX - ((proc_DELTA_X_b == MPI_PROC_NULL) ? 0 : 1),
			biY - ((proc_DELTA_Y_b == MPI_PROC_NULL) ? 0 : 1));
	}
	if (vtk_3_stream) {
		print_vtk_3(vtk_3_stream, vtk_dataName, nX, nY);
	}
	if (vtk_4_stream) {
		print_vtk_4(vtk_4_stream,
			aiX, aiY, biX, biY,
			aiX + ((proc_DELTA_X_a == MPI_PROC_NULL) ? 0 : 1),
			aiY + ((proc_DELTA_Y_a == MPI_PROC_NULL) ? 0 : 1),
			biX - ((proc_DELTA_X_b == MPI_PROC_NULL) ? 0 : 1),
			biY - ((proc_DELTA_Y_b == MPI_PROC_NULL) ? 0 : 1),
			T);
	}
	if (answer_function) {
		maxnorm_err = 0.0L;
		for (iY = aiY+1; iY <= biY-1; ++iY) {
			for (iX = aiX+1; iX <= biX-1; ++iX) {
				j = j_from_iXY(iX-aiX, niX, iY-aiY);
				normterm_err = fabsl(T[j] - answer_function(
					x_from_i(iX, aX, bX, nX),
					x_from_i(iY, aY, bY, nY)));
				if (normterm_err > maxnorm_err) {
					maxnorm_err = normterm_err;
				}
			}
		}
		MPI_Allreduce(
			&maxnorm_err,
			&maxnorm_err_recvbuf,
			1, MPI_LONG_DOUBLE,
			MPI_MAX, comm_cart);
		maxnorm_err = maxnorm_err_recvbuf;
		if (err_stream) fprintf(err_stream,
			"%.*Le\n",
			DECIMAL_DIG, maxnorm_err);
	}
	time2 = MPI_Wtime();
	if (time_stream) fprintf(time_stream,
		"%f\t",
		time2 - time1);

	free(S);
	free(T);
	if (do_jacobi_not_gaussseidel)
		free(T2);
	free(proc_DELTA_X_a_border_sendbuf);
	free(proc_DELTA_X_b_border_sendbuf);
	free(proc_DELTA_Y_a_border_sendbuf);
	free(proc_DELTA_Y_b_border_sendbuf);
	free(proc_DELTA_X_a_border_recvbuf);
	free(proc_DELTA_X_b_border_recvbuf);
	free(proc_DELTA_Y_a_border_recvbuf);
	free(proc_DELTA_Y_b_border_recvbuf);
	return rv;
}

/**
 * @return 2 if invalid argument.
 */
int point_gridcoord_block_from_proc_coord(
	const unsigned long long num_proc_coord,
	const unsigned long long proc_coord,
	const unsigned long long num_point_coord,
	const unsigned short do_nodecentered_not_cellcentered,
	unsigned long long *block_min_point_gridcoord,
	unsigned long long *block_max_point_gridcoord)
{
	if (proc_coord >= num_proc_coord) return 2;
	if (do_nodecentered_not_cellcentered) {
		if (num_point_coord < num_proc_coord) return 2;
	} else {
		if (num_point_coord < num_proc_coord) return 2;
	}
	*block_min_point_gridcoord =
		do_nodecentered_not_cellcentered ?
		(num_point_coord-2) * proc_coord / num_proc_coord :
		num_point_coord * proc_coord / num_proc_coord;
	*block_max_point_gridcoord =
		do_nodecentered_not_cellcentered ?
		(num_point_coord-2) * (proc_coord+1) / num_proc_coord + 1 :
		num_point_coord * (proc_coord+1) / num_proc_coord - 1;
	return 0;
}

int main_cart(
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
	const MPI_Comm comm_old,
	const int num_proc_coordX,
	const int num_proc_coordY,
	const long double max_maxnorm_iterdiff,     /* negative to disable */
	const unsigned short do_jacobi_not_gaussseidel,
	FILE *vtk_1_stream,                         /* NULL to disable */
	FILE *vtk_2_stream,                         /* NULL to disable */
	FILE *vtk_3_stream,                         /* NULL to disable */
	FILE *vtk_4_stream,                         /* NULL to disable */
	const char *vtk_title,
	const char *vtk_dataName,
	FILE *time_stream,                          /* NULL to disable */
	FILE *prog_stream,                          /* NULL to disable */
	FILE *err_stream)                           /* NULL to disable */
{
	static const int num_dim = 2;
	int num_proc_coords[2] = { num_proc_coordX, num_proc_coordY };
	int proc_coords[2];
	int periodicity[2] = { 0, 0 };
	MPI_Comm comm_cart;
	unsigned long long aiX, aiY, biX, biY;
	int proc_DELTA_X_a, proc_DELTA_X_b, proc_DELTA_Y_a, proc_DELTA_Y_b;

	/* Return value. */
	int rv = 0;

	/* ------ End of variable declarations; start of procedures. ------ */

	if ((rv = MPI_Cart_create(
		comm_old,
		num_dim,
		num_proc_coords,
		periodicity,
		1,
		&comm_cart)))
		return rv;
	if ((rv = MPI_Cart_get(
		comm_cart,
		num_dim,
		num_proc_coords,
		periodicity,
		proc_coords)))
		return rv;
	if ((rv = point_gridcoord_block_from_proc_coord(
		(unsigned long long) num_proc_coords[0],
		(unsigned long long) proc_coords[0],
		nX, 1, &aiX, &biX)))
		return rv;
	if ((rv = point_gridcoord_block_from_proc_coord(
		(unsigned long long) num_proc_coords[1],
		(unsigned long long) proc_coords[1],
		nY, 1, &aiY, &biY)))
		return rv;
	/*
	 * https://open-mpi.org//doc/current/man3/MPI_Cart_shift.3.php
	 * https://stackoverflow.com/questions/20813185
	 * https://computing.llnl.gov/tutorials/mpi#Virtual_Topologies
	 */
	if ((rv = MPI_Cart_shift(
		comm_cart, 0, 1, &proc_DELTA_X_a, &proc_DELTA_X_b)))
		return rv;
	if ((rv = MPI_Cart_shift(
		comm_cart, 1, 1, &proc_DELTA_Y_a, &proc_DELTA_Y_b)))
		return rv;
	if (time_stream) fprintf(time_stream,
		"%Lg\t%Lg\t%Lg\t%Lg\t%llu\t%llu\t%d\t%d\t%d\t%d\t",
		aX, aY, bX, bY, nX, nY,
		num_proc_coords[0], num_proc_coords[1],
		proc_coords[0], proc_coords[1]);
	if (err_stream) fprintf(err_stream,
		"%Lg\t%Lg\t%Lg\t%Lg\t%llu\t%llu\t",
		aX, aY, bX, bY, nX, nY);
	if ((rv = do_project2(
		source_function,
		boundary_value_function,
		answer_function,
		aX,
		aY,
		bX,
		bY,
		nX,
		nY,
		comm_cart,
		aiX,
		aiY,
		biX,
		biY,
		proc_DELTA_X_a,
		proc_DELTA_X_b,
		proc_DELTA_Y_a,
		proc_DELTA_Y_b,
		max_maxnorm_iterdiff,
		do_jacobi_not_gaussseidel,
		vtk_1_stream,
		vtk_2_stream,
		vtk_3_stream,
		vtk_4_stream,
		vtk_title,
		vtk_dataName,
		time_stream,
		prog_stream,
		err_stream)))
		return rv;
	if ((rv = MPI_Comm_free(&comm_cart)))
		return rv;
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
	/* MPI. */
	static const MPI_Comm comm_old = MPI_COMM_WORLD;
	static const int rootproc = 0;
	int num_proc;
	int proc;
	int num_proc_coordX;
	int num_proc_coordY;

	/* File streams. */
	int num_proc_string_length;
	char *vtk_streams_filename_prefix;
	char *time_stream_filename_prefix;
	int vtk_1_stream_filename_size;
	int vtk_2_stream_filename_size;
	int vtk_3_stream_filename_size;
	int vtk_4_stream_filename_size;
	int time_stream_filename_size;
	char *vtk_1_stream_filename;
	char *vtk_2_stream_filename;
	char *vtk_3_stream_filename;
	char *vtk_4_stream_filename;
	char *time_stream_filename;
	FILE *vtk_1_stream = NULL;
	FILE *vtk_2_stream = NULL;
	FILE *vtk_3_stream = NULL;
	FILE *vtk_4_stream = NULL;
	FILE *time_stream = NULL;
	FILE *prog_stream = NULL;
	FILE *err_stream = NULL;

	/* Variables for timing. */
	double time1, time2;

	/* Return value. */
	int rv = 0;

	/* ------ End of variable declarations; start of procedures. ------ */

	MPI_Init(&argc, &argv);
	time1 = MPI_Wtime();
	MPI_Comm_size(comm_old, &num_proc);
	MPI_Comm_rank(comm_old, &proc);
	num_proc_string_length = snprintf(NULL, 0, "%d", num_proc);
	if (argc < 18) return 2;
	num_proc_coordX = strtoull(argv[1], NULL, 10);
	num_proc_coordY = strtoull(argv[2], NULL, 10);
	if (argv[14][0] != '\0') {
		vtk_streams_filename_prefix = argv[14];
		if (proc == rootproc) {
			vtk_1_stream_filename_size = 1 + snprintf(NULL, 0,
				"%s%s%s", vtk_streams_filename_prefix,
				"_1", ".vtk"
			);
			vtk_3_stream_filename_size = 1 + snprintf(NULL, 0,
				"%s%s%s", vtk_streams_filename_prefix,
				"_3", ".vtk"
			);
			if (!(vtk_1_stream_filename =
				malloc(vtk_1_stream_filename_size *
					sizeof *vtk_1_stream_filename)))
				return 2;
			if (!(vtk_3_stream_filename =
				malloc(vtk_3_stream_filename_size *
					sizeof *vtk_3_stream_filename)))
				return 2;
			snprintf(
				vtk_1_stream_filename,
				vtk_1_stream_filename_size,
				"%s%s%s", vtk_streams_filename_prefix,
				"_1", ".vtk");
			snprintf(
				vtk_3_stream_filename,
				vtk_3_stream_filename_size,
				"%s%s%s", vtk_streams_filename_prefix,
				"_3", ".vtk");
			vtk_1_stream = fopen(vtk_1_stream_filename, "w");
			vtk_3_stream = fopen(vtk_3_stream_filename, "w");
		}
		vtk_2_stream_filename_size = 1 + snprintf(NULL, 0,
			"%s%s%d%s", vtk_streams_filename_prefix,
			"_2_", num_proc, ".vtk"
		);
		vtk_4_stream_filename_size = 1 + snprintf(NULL, 0,
			"%s%s%d%s", vtk_streams_filename_prefix,
			"_4_", num_proc, ".vtk"
		);
		if (!(vtk_2_stream_filename =
			malloc(vtk_2_stream_filename_size *
				sizeof *vtk_2_stream_filename)))
			return 2;
		if (!(vtk_4_stream_filename =
			malloc(vtk_4_stream_filename_size *
				sizeof *vtk_4_stream_filename)))
			return 2;
		snprintf(
			vtk_2_stream_filename,
			vtk_2_stream_filename_size,
			"%s%s%0*d%s", vtk_streams_filename_prefix,
			"_2_", num_proc_string_length, proc, ".vtk");
		snprintf(
			vtk_4_stream_filename,
			vtk_4_stream_filename_size,
			"%s%s%0*d%s", vtk_streams_filename_prefix,
			"_4_", num_proc_string_length, proc, ".vtk");
		vtk_2_stream = fopen(vtk_2_stream_filename, "w");
		vtk_4_stream = fopen(vtk_4_stream_filename, "w");
	}
	if (argv[17][0] != '\0') {
		time_stream_filename_prefix = argv[17];
		time_stream_filename_size = 1 + snprintf(NULL, 0,
			"%s%s%d%s", time_stream_filename_prefix,
			"_", num_proc, "_time.tsv"
		);
		if (!(time_stream_filename =
			malloc(time_stream_filename_size *
				sizeof *time_stream_filename)))
			return 2;
		snprintf(
			time_stream_filename,
			time_stream_filename_size,
			"%s%s%0*d%s", time_stream_filename_prefix,
			"_", num_proc_string_length, proc, "_time.tsv");
		time_stream = fopen(time_stream_filename, "w");
	}
	if (argv[18][0] != '\0') prog_stream = fopen(argv[18], "w");
	if (argv[19][0] != '\0') err_stream = fopen(argv[19], "w");
	if (vtk_1_stream) setbuf(vtk_1_stream, NULL);
	if (vtk_2_stream) setbuf(vtk_2_stream, NULL);
	if (vtk_3_stream) setbuf(vtk_3_stream, NULL);
	if (vtk_4_stream) setbuf(vtk_4_stream, NULL);
	if (time_stream) setbuf(time_stream, NULL);
	if (prog_stream) setbuf(prog_stream, NULL);
	if (err_stream) setbuf(err_stream, NULL);
	rv = main_cart(
		strtoull(argv[3], NULL, 10) ? source1 : source2,
		strtoull(argv[4], NULL, 10) ? boundary_value1 : boundary_value2,
		strtoull(argv[5], NULL, 10) ? Tans_verification : NULL,
		strtold(argv[6], NULL),
		strtold(argv[7], NULL),
		strtold(argv[8], NULL),
		strtold(argv[9], NULL),
		strtoull(argv[10], NULL, 10),
		strtoull(argv[11], NULL, 10),
		comm_old,
		num_proc_coordX,
		num_proc_coordY,
		strtold(argv[12], NULL),
		(unsigned short) strtoull(argv[13], NULL, 10),
		(proc == rootproc) ? vtk_1_stream : NULL,
		vtk_2_stream,
		(proc == rootproc) ? vtk_3_stream : NULL,
		vtk_4_stream,
		argv[15],
		argv[16],
		time_stream,
		(proc == rootproc) ? prog_stream : NULL,
		(proc == rootproc) ? err_stream : NULL);
	if (vtk_1_stream) fclose(vtk_1_stream);
	if (vtk_2_stream) fclose(vtk_2_stream);
	if (vtk_3_stream) fclose(vtk_3_stream);
	if (vtk_4_stream) fclose(vtk_4_stream);
	if (prog_stream) fclose(prog_stream);
	if (err_stream) fclose(err_stream);
	time2 = MPI_Wtime();
	if (time_stream) fprintf(time_stream,
		"%f\n",
		time2 - time1);
	if (time_stream) fclose(time_stream);
	MPI_Finalize();
	return rv;
}
