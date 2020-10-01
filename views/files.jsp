<%--
  Created by IntelliJ IDEA.
  User: User
  Date: 27.09.2020
  Time: 15:26
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Хранилище файлов Excel</title>
    <style type="text/css">
        body{
            display: flex;
            justify-content: center;
        }
        #allFilesButtons{
            display: flex;
            flex-direction: column;
            margin-top: 7em;
            width: 15%;
        }
        #allFilesButtons button{
            border-width: 3px;
            border-color:  #79489c;
            width: 100%;
            height: 100%;
            margin-bottom: 2em;
            font-weight: bold;
            font-size: 1.5em;
            line-height: 1.7em;
            overflow: hidden;
            color:#79489c;
            background-color:#ffffff;
        }
    </style>
</head>
<body>
    <%@ page import="logic.ExcelHandler, java.util.HashMap, java.util.Map, java.util.Set, java.util.Iterator"%>
    <div id="allFilesButtons">
        <%
            HashMap<Integer, String> files = ExcelHandler.getFilenamesFromDb();
            Set<Map.Entry<Integer, String>> setOfFiles = files.entrySet();
            Iterator<Map.Entry<Integer, String>> iter = setOfFiles.iterator();
            Map.Entry<Integer, String> file;
        %>

        <%while(iter.hasNext()){
            file = iter.next();%>
            <button onclick="location.href='/showDefiniteFile?file_id=<%=file.getKey()%>&&file_name=<%=file.getValue()%>'">
                <%=file.getValue()%>
            </button>
        <%}%>
        <button onclick="location.href='/views/index.html'">Назад</button>
    </div>
</body>
</html>
