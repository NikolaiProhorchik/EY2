<%--
  Created by IntelliJ IDEA.
  User: User
  Date: 29.09.2020
  Time: 12:52
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <link rel="stylesheet" type="text/css" href="../styles/stylesForTable.css">
    <title><%=request.getParameter("file_name")%></title>
</head>
<body>
    <%@ page import="java.sql.*"%>
    <%@ page import="java.text.DecimalFormat"%>
    <%final int file_id = Integer.parseInt(request.getParameter("file_id"));
      final String url = "jdbc:mysql://localhost:3306/DATABASE2?serverTimezone=Europe/Minsk";
      final String user = "root";
      final String password = "49MyData";
      final DecimalFormat decForm = new DecimalFormat("#0.00");

      Connection con;
      Statement stmt;
      Statement tempStmt;
      ResultSet rs;
      ResultSet tempRs;
      String query;

      int curr_class;
      int curr_group;
      double tempAsset;
      double tempLiability;
      double tempMin;
      double assetInGroup = 0;
      double liabilityInGroup = 0;
      double assetInClass = 0;
      double liabilityInClass = 0;
      double finalAsset = 0;
      double finalLiability = 0;
      boolean cond;

      try {
          Class.forName("com.mysql.cj.jdbc.Driver");
      }
      catch(Exception ex){ex.printStackTrace();}
    %>
    <%try {
          con = DriverManager.getConnection(url, user, password);
          stmt = con.createStatement();
          tempStmt = con.createStatement();
    %>
    <table>
        <tr>
            <th rowspan="2" class="first">Б/сч</th>
            <th colspan="2">ВХОДЯЩЕЕ САЛЬДО</th>
            <th colspan="2">ОБОРОТЫ</th>
            <th colspan="2">ИСХОДЯЩЕЕ САЛЬДО</th>
        </tr>
        <tr>
            <th>Актив</th>
            <th>Пассив</th>
            <th>Дебет</th>
            <th>Кредит</th>
            <th>Актив</th>
            <th>Пассив</th>
        </tr>
    <%
          //получаем все записи файла
          query = String.format("SELECT * FROM NOTES WHERE file_id=%d ORDER BY class_id, group_id, account_id;", file_id);
          rs = stmt.executeQuery(query);
          rs.next();

          while(true){
              curr_class = rs.getInt(2);
              curr_group = rs.getInt(3);

              //заполняем название очердного класса
              query = String.format("SELECT CLASS_NAME FROM CLASSES WHERE id=%d;", curr_class);
              tempRs = tempStmt.executeQuery(query);
              tempRs.next();
    %>
                <tr>
                    <th colspan="7">КЛАСС  <%=curr_class + "  " + tempRs.getString(1)%></th>
                </tr>
    <%
            do{
                do{
                    tempAsset = rs.getDouble(5) + rs.getDouble(7);//входящие активы + обороты
                    tempLiability = rs.getDouble(6) + rs.getDouble(8);//входящие пассивы + обороты
                    tempMin = Math.min(tempAsset, tempLiability);//для рассчёта исходящего сальдо
                    assetInGroup += tempAsset - tempMin;//добавляем в исходящие активы группы
                    liabilityInGroup += tempLiability - tempMin;//добавляем в исходящие пассивы группы
    %>
                    <tr>
                        <td><%=(curr_class * 10 + curr_group) * 100 + rs.getInt(4)%></td>
                        <td><%=decForm.format(rs.getDouble(5))%></td>
                        <td><%=decForm.format(rs.getDouble(6))%></td>
                        <td><%=decForm.format(rs.getDouble(7))%></td>
                        <td><%=decForm.format(rs.getDouble(8))%></td>
                        <td><%=decForm.format(tempAsset - tempMin)%></td>
                        <td><%=decForm.format(tempLiability - tempMin)%></td>
                    </tr>
    <%
                        if(!(cond = rs.next())) {
                            break;
                        }
              }while(curr_group == rs.getInt(3));
                //итог по группе
                query = String.format("SELECT SUM(incoming_asset), SUM(incoming_liability), " +
                        "SUM(debit), SUM(credit) " +
                        "FROM NOTES WHERE file_id=%d AND class_id=%d AND group_id=%d;", file_id, curr_class, curr_group);
                tempRs = tempStmt.executeQuery(query);
                tempRs.next();
    %>
                <tr>
                    <th><%=curr_class * 10 + curr_group%></th>
                    <th><%=decForm.format(tempRs.getDouble(1))%></th>
                    <th><%=decForm.format(tempRs.getDouble(2))%></th>
                    <th><%=decForm.format(tempRs.getDouble(3))%></th>
                    <th><%=decForm.format(tempRs.getDouble(4))%></th>
                    <th><%=decForm.format(assetInGroup)%></th>
                    <th><%=decForm.format(liabilityInGroup)%></th>
                </tr>
    <%
                //завершение обработки группы, добавление значения исходящего сальдо класса
                assetInClass += assetInGroup;
                liabilityInClass += liabilityInGroup;
                assetInGroup = 0;
                liabilityInGroup = 0;
                if(!cond){
                    break;
                }
                curr_group = rs.getInt(3);
            }while(curr_class == rs.getInt(2));
            //итог по классу
            query = String.format("SELECT SUM(incoming_asset), SUM(incoming_liability), " +
                    "SUM(debit), SUM(credit) " +
                    "FROM NOTES WHERE file_id=%d AND class_id=%d;", file_id, curr_class);
            tempRs = tempStmt.executeQuery(query);
            tempRs.next();
    %>
            <tr>
                <th>ПО КЛАССУ</th>
                <th><%=decForm.format(tempRs.getDouble(1))%></th>
                <th><%=decForm.format(tempRs.getDouble(2))%></th>
                <th><%=decForm.format(tempRs.getDouble(3))%></th>
                <th><%=decForm.format(tempRs.getDouble(4))%></th>
                <th><%=decForm.format(assetInClass)%></th>
                <th><%=decForm.format(liabilityInClass)%></th>
            </tr>
    <%
            //завершение обработки класса, добавление значения общего исходящего сальдо
            finalAsset += assetInClass;
            finalLiability += liabilityInClass;
            assetInClass = 0;
            liabilityInClass = 0;
            if(!cond){
                break;
            }
          }
        //общий итог
        query = String.format("SELECT SUM(incoming_asset), SUM(incoming_liability), " +
                "SUM(debit), SUM(credit) " +
                "FROM NOTES WHERE file_id=%d;", file_id);
        tempRs = tempStmt.executeQuery(query);
        tempRs.next();
    %>
        <tr>
            <th>БАЛАНС</th>
            <th><%=decForm.format(tempRs.getDouble(1))%></th>
            <th><%=decForm.format(tempRs.getDouble(2))%></th>
            <th><%=decForm.format(tempRs.getDouble(3))%></th>
            <th><%=decForm.format(tempRs.getDouble(4))%></th>
            <th><%=decForm.format(finalAsset)%></th>
            <th><%=decForm.format(finalLiability)%></th>
        </tr>
    </table>
    <%}
    catch (SQLException sqlEx){
        sqlEx.printStackTrace();
    }
    %>
</body>
</html>
