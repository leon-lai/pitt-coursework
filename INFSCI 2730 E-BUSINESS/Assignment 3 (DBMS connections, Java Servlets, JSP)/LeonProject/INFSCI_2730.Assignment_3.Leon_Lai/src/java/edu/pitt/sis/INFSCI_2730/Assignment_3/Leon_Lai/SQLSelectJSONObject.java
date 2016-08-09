package edu.pitt.sis.INFSCI_2730.Assignment_3.Leon_Lai;
import org.json.JSONArray;
import org.json.JSONObject;
import java.sql.SQLException;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
/**
 * @author leon
 * @version 2016-03-18
 */
public class SQLSelectJSONObject extends JSONObject {
  public static JSONArray toJSONArray(final ResultSet rs) throws SQLException {
    final JSONArray json = new JSONArray();
    final ResultSetMetaData rsmd = rs.getMetaData();
    final int columnCount = rsmd.getColumnCount();
    final String[] columnNames = new String[columnCount];
    for(int columnIndex = 1; columnIndex <= columnCount; ++columnIndex) {
      columnNames[columnIndex - 1] = rsmd.getColumnName(columnIndex);
    }
    while(rs.next()) {
      final JSONObject row = new JSONObject();
      for(String columnName : columnNames) {
        row.put(columnName, rs.getObject(columnName));
      }
      json.put(row);
    }
    return json;
  }
}
