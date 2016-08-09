/* 2015-04-03 Leon Lai <Leon.Lai@pitt.edu> */

import java.text.SimpleDateFormat;
import java.util.Date;
import java.io.PrintStream;
import java.util.Collections;
import java.util.ArrayList;
import java.util.HashMap;
import java.io.BufferedReader;
import java.io.FileReader;

public class TransactionsDataGenerator
{
	public static void main(String[] arguments) throws Exception
	{
		final BufferedReader salespersons_reader
		= new BufferedReader(new FileReader("salespersons.csv"));
		final BufferedReader products_reader
		= new BufferedReader(new FileReader("products.csv"));
		final PrintStream transaction_groups
		= new PrintStream("transaction_groups.csv");
		final PrintStream transactions
		= new PrintStream("transactions.csv");

		new TransactionsDataGenerator().go(salespersons_reader, products_reader, transaction_groups, transactions);
	}

	public void go(final BufferedReader salespersons_reader, final BufferedReader products_reader, final PrintStream transaction_groups, final PrintStream transactions) throws Exception
	{
		/* Customer IDs := int's between the two int's below, inclusive */
		final int CUSTOMER_ID_RANGE_LOWER_BOUND = 1;
		final int CUSTOMER_ID_RANGE_UPPER_BOUND = 100000;

		/* min <= x < max */
		final int MIN_NUM_TRANSACTION_GROUPS_PER_CUSTOMER = 0;
		final int MAX_NUM_TRANSACTION_GROUPS_PER_CUSTOMER = 15;

		/* Date range := min <= x < max */
		final SimpleDateFormat SDF
		= new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");
		final Date MIN_TRANSACTION_GROUP_DATE
		= SDF.parse("2012-01-01T00:00:00");
		final Date MAX_TRANSACTION_GROUP_DATE
		= SDF.parse("2014-01-01T00:00:00");

		ArrayList<Integer> salespersons = new ArrayList<Integer>();
		salespersons_reader.readLine(); // Skip header row
		while (true)
		{
			String salesperson = salespersons_reader.readLine();
			if (salesperson == null) break;
			/* Get salespersons.employee_ID */
			salespersons.add(Integer.parseInt(salesperson.split(",")[0]));
		}

		/* Product IDs := int's between the two int's below, inclusive */
		final int PRODUCT_ID_RANGE_LOWER_BOUND = 1;
		final int PRODUCT_ID_RANGE_UPPER_BOUND = 85;

		HashMap<Integer,Double> products = new HashMap<Integer,Double>();
		products_reader.readLine(); // Skip header row
		while (true)
		{
			String product = products_reader.readLine();
			if (product == null) break;
			String[] product_tuple = product.split(",");
			/* Get products.product_ID and products.price */
			products.put(Integer.parseInt(product_tuple[0]), Double.parseDouble(product_tuple[4]));
		}

		/* min <= x < max */
		final int MIN_NUM_TRANSACTIONS_PER_TRANSACTION_GROUP = 1;
		final int MAX_NUM_TRANSACTIONS_PER_TRANSACTION_GROUP = 4;

		/* min <= x < max */
		final int MIN_PRODUCT_QUANTITY_PER_TRANSACTION = 1;
		final int MAX_PRODUCT_QUANTITY_PER_TRANSACTION = 10;



		transaction_groups.println("ID,date,salesperson,customer");
		transactions.println("ID,product,product_quantity,amount_paid,transaction_group");

		ArrayList<String> tgs = new ArrayList<String>();
		for (
			int customer_id = CUSTOMER_ID_RANGE_LOWER_BOUND, num_salespersons = salespersons.size();
			customer_id <= CUSTOMER_ID_RANGE_UPPER_BOUND;
			customer_id++
		){
			int tg_I = randomBetween(MIN_NUM_TRANSACTION_GROUPS_PER_CUSTOMER, MAX_NUM_TRANSACTION_GROUPS_PER_CUSTOMER);
			for (int tg_i = 1; tg_i <= tg_I; tg_i++)
			{
				tgs.add(
					SDF.format(new Date(randomBetween(MIN_TRANSACTION_GROUP_DATE.getTime(), MAX_TRANSACTION_GROUP_DATE.getTime())))
					+ "," + salespersons.get(randomBetween(0, num_salespersons))
					+ "," + customer_id
				);
			}
		}
		Collections.sort(tgs);

		int tg_id = 1;
		int t_id = 1;
		for (String tg : tgs)
		{
			transaction_groups.println(tg_id + "," + tg);

			int t_I = randomBetween(MIN_NUM_TRANSACTIONS_PER_TRANSACTION_GROUP, MAX_NUM_TRANSACTIONS_PER_TRANSACTION_GROUP);
			for (int t_i = 1; t_i <= t_I; t_i++)
			{
				int product_id = randomBetween(PRODUCT_ID_RANGE_LOWER_BOUND,PRODUCT_ID_RANGE_UPPER_BOUND);
				int quantity = randomBetween(MIN_PRODUCT_QUANTITY_PER_TRANSACTION,MAX_PRODUCT_QUANTITY_PER_TRANSACTION);
				transactions.println(
					"" + t_id
					+ "," + product_id
					+ "," + quantity
					+ "," + (Math.round(products.get(product_id) * quantity * 100.0) / 100.0)
					+ "," + tg_id
				);
				t_id++;
			}

			tg_id++;
		}
	}

	private static long randomBetween(long lowerInclusive, long upperExclusive)
	{
		return lowerInclusive + (long)((upperExclusive - lowerInclusive) * Math.random());
	}

	private static int randomBetween(int lowerInclusive, int upperExclusive)
	{
		return lowerInclusive + (int)((upperExclusive - lowerInclusive) * Math.random());
	}

	private static short randomBetween(short lowerInclusive, short upperExclusive)
	{
		return (short)(lowerInclusive + (short)((upperExclusive - lowerInclusive) * Math.random()));
	}

	private static byte randomBetween(byte lowerInclusive, byte upperExclusive)
	{
		return (byte)(lowerInclusive + (byte)((upperExclusive - lowerInclusive) * Math.random()));
	}

	private static double randomBetween(double lowerInclusive, double upperExclusive)
	{
		return lowerInclusive + (double)((upperExclusive - lowerInclusive) * Math.random());
	}

	private static float randomBetween(float lowerInclusive, float upperExclusive)
	{
		return lowerInclusive + (float)((upperExclusive - lowerInclusive) * Math.random());
	}
}
