package logic;

import java.io.*;
import java.sql.*;
import java.text.DecimalFormat;
import java.util.Iterator;
import java.util.HashMap;

import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellType;

public class ExcelHandler {
    private static final String url = "jdbc:mysql://localhost:3306/DATABASE2?serverTimezone=Europe/Minsk";
    private static final String user = "root";
    private static final String password = "49MyData";
    private static final DecimalFormat decForm = new DecimalFormat("#0.00");
    private static Connection con;
    private static Statement stmt;
    private static ResultSet rs;
    private static String query;

    //проверка существования файла
    public static boolean isExistInDb(String filename){
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        }
        catch(Exception ex){ex.printStackTrace();}
        try {
            con = DriverManager.getConnection(url, user, password);
            stmt = con.createStatement();

            query = String.format("SELECT id FROM FILES WHERE file_name='%s';", filename);
            rs = stmt.executeQuery(query);

            return rs.next();
        }
        catch (SQLException sqlEx){
            sqlEx.printStackTrace();
            return true;
        }
        finally {
            finalBlock();
        }
    }

    //используется при выведении списка доступных файлов
    public static HashMap<Integer, String> getFilenamesFromDb(){
        HashMap<Integer, String> files = new HashMap<>();

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        }
        catch(Exception ex){ex.printStackTrace();}
        try {
            con = DriverManager.getConnection(url, user, password);
            stmt = con.createStatement();

            query = "SELECT * FROM FILES ORDER BY ID;";
            rs = stmt.executeQuery(query);

            while(rs.next()){
                files.put(rs.getInt(1), rs.getString(2));
            }

            return files;
        }
        catch (SQLException sqlEx){
            sqlEx.printStackTrace();
            return files;
        }
        finally {
            finalBlock();
        }
    }

    public static boolean parseExcelToDb(String path, String filename) throws IOException{
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        }
        catch(Exception ex){ex.printStackTrace();}
        try {
            con = DriverManager.getConnection(url, user, password);
            stmt = con.createStatement();

            //добавляем имя нового файла в таблицу
            query = String.format("INSERT INTO FILES (FILE_NAME) VALUES('%s');", filename);
            stmt.executeUpdate(query);
            query = String.format("SELECT id FROM FILES WHERE file_name='%s';", filename);
            rs = stmt.executeQuery(query);
            rs.next();
            int fileId = rs.getInt(1);

            HSSFWorkbook excelBook = new HSSFWorkbook(new FileInputStream(path + filename));
            HSSFSheet excelSheet = excelBook.getSheetAt(0);
            Iterator<Row> rowIter = excelSheet.iterator();
            Row row;
            Cell cell;
            String line;
            String[] className;

            //ищем строку со словом "КЛАСС"
            while (true) {
                row = rowIter.next();
                cell = row.getCell(0);

                if(cell.getCellType() == CellType.STRING){
                    line = cell.getStringCellValue();
                    className = line.split("\\s{2}");
                    if (className[0].equals("КЛАСС")) {
                        //найдя строку со словом "КЛАСС", запускаем обработчик класса
                        handleClass(rowIter, fileId, Integer.parseInt(className[1]));
                    } else if (line.equals("БАЛАНС")) {
                        break;
                    }
                }
            }

            return true;
        }
        catch (SQLException sqlEx){
            sqlEx.printStackTrace();
            return false;
        }
        finally {
            finalBlock();
        }
    }

    private static void handleClass(Iterator<Row> rowIter, int fileId, int classId) throws SQLException{
        Iterator<Cell> cellIter;
        Row row;
        Cell cell;
        int buffer;
        int groupId;
        int accountId;

        while(true){
            row = rowIter.next();
            cellIter = row.iterator();
            cell = row.getCell(0);

            if(cell.getCellType() == CellType.STRING){
                if (cell.getStringCellValue().length() == 4) {
                    //разбиваем составной код б/сч на код группы и код счёта
                    buffer = Integer.parseInt(cellIter.next().getStringCellValue());
                    groupId = buffer / 100 % 10;
                    accountId = buffer % 100;

                    //если в буффере код счёта, тогда записываем
                    if (buffer > 99) {
                        query = String.format("INSERT INTO NOTES VALUES(%d, %d, %d, %d, %s, %s, %s, %s);",
                                fileId, classId, groupId, accountId,
                                decForm.format(cellIter.next().getNumericCellValue()).replace(",", "."),
                                decForm.format(cellIter.next().getNumericCellValue()).replace(",", "."),
                                decForm.format(cellIter.next().getNumericCellValue()).replace(",", "."),
                                decForm.format(cellIter.next().getNumericCellValue()).replace(",", "."));
                        stmt.executeUpdate(query);
                    }
                } else {
                    break;
                }
            }
        }
    }

    private static void finalBlock(){
        try {con.close();} catch(SQLException se){se.printStackTrace();}
        try {stmt.close();} catch(SQLException se){se.printStackTrace();}
        try {rs.close();} catch(SQLException se){se.printStackTrace();}
    }
}
