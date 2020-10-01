package servlets;

import java.io.File;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.http.Part;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

import logic.ExcelHandler;

@WebServlet("/uploadFile")
@MultipartConfig(fileSizeThreshold=1024*1024*2, // 2MB
                maxFileSize=1024*1024*10,      // 10MB
                maxRequestSize=1024*1024*50)   // 50MB
public class fileReceiver extends HttpServlet {
    //директория для сохранения загруженных файлов
    private static final String SAVE_DIR = "uploadFile";

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException{
        //получаем полный путь к веь-приложению
        String appPath = request.getServletContext().getRealPath("");
        //добвляем к нему директорию сохранения
        String savePath = appPath + File.separator + SAVE_DIR;

        //создаём директорию, если она не существует
        File fileSaveDir = new File(savePath);
        if (!fileSaveDir.exists()) {
            fileSaveDir.mkdir();
        }

        boolean cond = false;

        for (Part part : request.getParts()) {
            String fileName = extractFileName(part);
            //если имя файла - полный путь, переопредляем его
            fileName = new File(fileName).getName();
            if(!ExcelHandler.isExistInDb(fileName)){
                String fullName = savePath + File.separator + fileName;
                //записываем в файл
                part.write(fullName);
                //импортим файл в базу данных
                cond = ExcelHandler.parseExcelToDb(savePath + File.separator, fileName) || cond;
                //удаляем файл
                new File(fullName).delete();
            }
        }

        //обработка результата загрузки
        if(cond){
            request.setAttribute("message", "Успешно загружено!");
        }
        else{
            request.setAttribute("message", "Файл уже существует!");
        }
        getServletContext().getRequestDispatcher("/messageUpload").forward(
                request, response);
    }

    //извлечение имени файла из HTTP header content-disposition
    private String extractFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] items = contentDisp.split(";");
        for (String s : items) {
            if (s.trim().startsWith("filename")) {
                return s.substring(s.indexOf("=") + 2, s.length()-1);
            }
        }
        return "";
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

    }
}
