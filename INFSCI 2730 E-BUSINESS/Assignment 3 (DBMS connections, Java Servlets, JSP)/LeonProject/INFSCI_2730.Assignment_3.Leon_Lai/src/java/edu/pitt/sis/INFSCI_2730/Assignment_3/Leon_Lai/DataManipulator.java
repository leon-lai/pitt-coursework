package edu.pitt.sis.INFSCI_2730.Assignment_3.Leon_Lai;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;
import java.sql.SQLException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.Date;
import java.util.LinkedList;
import java.util.List;
import java.util.Collections;
/**
 * @author leon
 * @version 2016-03-18
 * This class essentially encapsulates the database.
 * Methods are static because there is only one global database.
 * Refer to database_setup.sql for DDL.
 */
public class DataManipulator {
  public static Boolean createAccount(
    final String account, final String password_hash
  ) {
    if(account == null || password_hash == null) {
      return null;
    }
    try(
      final Connection connection = CONNECTION_POOL.getConnection();
      final PreparedStatement ps = connection.prepareStatement("Insert into Account(account, password_hash) values(LOWER(?), ?)")) {
      setParameters(ps, account, password_hash);
      switch(ps.executeUpdate()) {
        case (0): {
          return false;
        }
        case (1): {
          connection.commit();
          return true;
        }
      }
      connection.rollback();
    }
    catch(final SQLException t) {
    }
    return null;
  }
  public static Boolean isAccount(
    final String account, final String password_hash
  ) {
    if(account == null || password_hash == null) {
      return null;
    }
    try(
      final Connection connection = CONNECTION_POOL.getConnection();
      final PreparedStatement ps = connection.prepareStatement("Select * from Account where account = LOWER(?) and password_hash = ?")) {
      setParameters(ps, account, password_hash);
      final ResultSet rs = ps.executeQuery();
      return rs.next();
    }
    catch(final SQLException t) {
    }
    return null;
  }
  public static LinkedList<Item> getAvailableItems() {
    try(
      final Connection connection = CONNECTION_POOL.getConnection();
      final PreparedStatement ps = connection.prepareStatement("Select item, Item.* from Item natural join Item_on_shelf order by name, exp_date")) {
      final ResultSet rs = ps.executeQuery();
      final LinkedList<Item> ret = new LinkedList<>();
      while(rs.next()) {
        ret.add(new Item(
          rs.getLong(1),
          rs.getString(2),
          rs.getDouble(3),
          rs.getString(4),
          rs.getDouble(5),
          rs.getDate(6)
        ));
      }
      return ret;
    }
    catch(final SQLException t) {
    }
    return null;
  }
  public static LinkedList<Item> getCartItems(
    final String account
  ) {
    if(account == null) {
      return null;
    }
    try(
      final Connection connection = CONNECTION_POOL.getConnection();
      final PreparedStatement ps = connection.prepareStatement("Select item, Item.* from Item natural join Item_in_cart natural join Account where account = LOWER(?) order by name, exp_date")) {
      setParameters(ps, account);
      final ResultSet rs = ps.executeQuery();
      final LinkedList<Item> ret = new LinkedList<>();
      while(rs.next()) {
        ret.add(new Item(
          rs.getLong(1),
          rs.getString(2),
          rs.getDouble(3),
          rs.getString(4),
          rs.getDouble(5),
          rs.getDate(6)
        ));
      }
      return ret;
    }
    catch(final SQLException t) {
    }
    return null;
  }
  public static Double getCartTotalPriceUSD(
    final String account
  ) {
    if(account == null) {
      return null;
    }
    try(
      final Connection connection = CONNECTION_POOL.getConnection();
      final PreparedStatement ps = connection.prepareStatement("Select coalesce(sum(price_usd), 0) as price_usd from Item natural join Item_in_cart natural join Account where account = LOWER(?)")) {
      setParameters(ps, account);
      final ResultSet rs = ps.executeQuery();
      if(rs.next()) {
        return rs.getDouble(1);
      }
    }
    catch(final SQLException t) {
    }
    return null;
  }
  private static LinkedList<Long> moveItems(
    final String account, final long[] items, final boolean toShelf
  ) {
    if(account == null || items == null) {
      return null;
    }
    try(
      final Connection connection = CONNECTION_POOL.getConnection();
      final PreparedStatement psA = connection.prepareStatement(
        toShelf ?
          "Delete from Item_in_cart  where item = ?" :
          "Delete from Item_on_shelf where item = ?"
      );
      final PreparedStatement psB = connection.prepareStatement(
        toShelf ?
          "Insert into Item_on_shelf values (?)" :
          "Insert into Item_in_cart  values (?, ?)"
      )) {
      final LinkedList<Long> unmovedItems = new LinkedList<>();
      for(long item : items) {
        psA.setObject(1, item);
        psB.setObject(1, item);
        if(!toShelf) {
          psB.setObject(2, account);
        }
        // No need to check constraint violation--the delete comes first
        if(psA.executeUpdate() == 1 && psB.executeUpdate() == 1) {
          connection.commit();
        }
        else {
          connection.rollback();
          unmovedItems.add(item);
        }
      }
      return unmovedItems;
    }
    catch(final SQLException t) {
    }
    return null;
  }
  public static LinkedList<Long> moveToCart(
    final String account, final long[] items
  ) {
    return moveItems(account, items, false);
  }
  public static LinkedList<Long> removeFromCart(
    final String account, final long[] items
  ) {
    return moveItems(account, items, true);
  }
  public static Object removeAllFromCart(
    final String account
  ) {
    if(account == null) {
      return null;
    }
    try(
      final Connection connection = CONNECTION_POOL.getConnection();
      final PreparedStatement psA = connection.prepareStatement("Insert into Item_on_shelf select item from Item_in_cart where account = LOWER(?)");
      final PreparedStatement psB = connection.prepareStatement("Delete from Item_in_cart where account = LOWER(?)")) {
      setParameters(psA, account);
      setParameters(psB, account);
      if(psA.executeUpdate() == psB.executeUpdate()) {
        connection.commit();
        return new Object();
      }
      connection.rollback();
    }
    catch(final SQLException t) {
    }
    return null;
  }
  public static Long finalizeCart(
    final String account, final Date due_date, final String address
  ) {
    if(account == null || due_date == null) {
      return null;
    }
    try(final Connection connection = CONNECTION_POOL.getConnection()) {
      try(final PreparedStatement psA = connection.prepareStatement("Insert into Reservn(account, cue_date, due_date, address) values(?, CURRENT_TIMESTAMP, ?, ?)", PreparedStatement.RETURN_GENERATED_KEYS)) {
        setParameters(psA, account, due_date, address);
        psA.executeUpdate(); // No check this--check generated keys
        try(final ResultSet rsgk = psA.getGeneratedKeys()) {
          if(rsgk.next()) {
            final long reservn = rsgk.getLong(1);
            try(final PreparedStatement psB = connection.prepareStatement("Insert into Reservn_checked_out values(?)")) {
              setParameters(psB, reservn);
              final int rB = psB.executeUpdate();
              if(rB == 1) {
                try(
                  final PreparedStatement psC = connection.prepareStatement("Insert into Reservn_Item select ?, item from Item_in_cart where account = LOWER(?)");
                  final PreparedStatement psD = connection.prepareStatement("Insert into Item_checked_out select item from Item_in_cart where account = LOWER(?)");
                  final PreparedStatement psE = connection.prepareStatement("Delete from Item_in_cart where account = LOWER(?)")) {
                  setParameters(psC, reservn, account);
                  setParameters(psD, account);
                  setParameters(psE, account);
                  final int rC = psC.executeUpdate();
                  final int rD = psD.executeUpdate();
                  final int rE = psE.executeUpdate();
                  if(rC == rD && rD == rE) {
                    connection.commit();
                    return reservn;
                  }
                }
              }
            }
          }
        }
      }
      connection.rollback();
    }
    catch(final SQLException t) {
    }
    return null;
  }
  public static Receipt getReceipt(
    final String account, final long reservn
  ) {
    try(
      final Connection connection = CONNECTION_POOL.getConnection();
      final PreparedStatement psA = connection.prepareStatement("Select reservn, cue_date, due_date, address from Reservn where reservn = ? and account = ?");
      final PreparedStatement psB = connection.prepareStatement("Select item, name, weight, unit, price_usd from Item natural join Reservn_Item natural join Reservn where reservn = ? and account = ? order by name");
      final PreparedStatement psC = connection.prepareStatement("Select sum(price_usd) from Item natural join Reservn_Item natural join Reservn where reservn = ? and account = ?")) {
      setParameters(psA, reservn, account);
      setParameters(psB, reservn, account);
      setParameters(psC, reservn, account);
      try(
        final ResultSet rsA = psA.executeQuery();
        final ResultSet rsB = psB.executeQuery();
        final ResultSet rsC = psC.executeQuery()) {
        if(rsA.next() && rsC.next()) {
          final LinkedList<Receipt.Item> items = new LinkedList<>();
          while(rsB.next()) {
            items.add(new Receipt.Item(
              rsB.getLong(1),
              rsB.getString(2),
              rsB.getDouble(3),
              rsB.getString(4),
              rsB.getDouble(5)
            ));
          }
          return new Receipt(
            rsA.getLong(1),
            rsA.getTimestamp(2),
            rsA.getTimestamp(3),
            rsA.getString(4),
            items,
            rsC.getDouble(1)
          );
        }
      }
    }
    catch(final SQLException t) {
    }
    return null;
  }
  private DataManipulator() {
  }
  public static class Item {
    public final long item;
    public final String name;
    public final double weight;
    public final String unit;
    public final double price_usd;
    public final Date exp_date;
    public Item(
      final long item,
      final String name,
      final double weight,
      final String unit,
      final double price_usd,
      final Date exp_date
    ) {
      this.item = item;
      this.name = name;
      this.weight = weight;
      this.unit = unit;
      this.price_usd = price_usd;
      this.exp_date = exp_date;
    }
  }
  public static class Receipt {
    public final long reservn;
    public final Date cue_date;
    public final Date due_date;
    public final String address;
    public final List<Item> items;
    public final double total_price_usd;
    public Receipt(
      final long reservn,
      final Date cue_date,
      final Date due_date,
      final String address,
      final List<Item> items, final double total_price_usd
    ) {
      this.reservn = reservn;
      this.cue_date = cue_date;
      this.due_date = due_date;
      this.address = address;
      this.items = items == null ? null : Collections.unmodifiableList(items);
      this.total_price_usd = total_price_usd;
    }
    public static class Item {
      public final long item;
      public final String name;
      public final double weight;
      public final String unit;
      public final double price_usd;
      public Item(
        final long item,
        final String name,
        final double weight,
        final String unit,
        final double price_usd
      ) {
        this.item = item;
        this.name = name;
        this.weight = weight;
        this.unit = unit;
        this.price_usd = price_usd;
      }
    }
  }
  private static final DataSource CONNECTION_POOL;
  static {
    try {
      final Context ctx = new InitialContext();
      final Context ctxJavaEE = (Context) ctx.lookup("java:comp/env");
      CONNECTION_POOL = (DataSource) ctxJavaEE.lookup("connection_pool");
    }
    catch(final NamingException t) {
      throw new ExceptionInInitializerError(t);
    }
  }
  private static void setParameters(
    final PreparedStatement ps, final Object... parameters
  ) throws SQLException {
    for(int index = 0, count = parameters.length; index < count; ++index) {
      ps.setObject(index + 1, parameters[index]);
    }
  }
}
