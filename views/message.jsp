<%--
  Created by IntelliJ IDEA.
  User: User
  Date: 27.09.2020
  Time: 11:04
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
        #container{
            display: flex;
            flex-direction: column;
        }
        #message{
            text-align: center;
            margin-top: 2em;
            height: 20%;
            font-weight: bold;
            font-size: 3em;
            color:#79489c;
        }
        #messageButton{
            margin: 7em 35% 0 35%;
            height: 3em;
            width: 30%;
        }
        #messageButton button{
            border: 0;
            width: 100%;
            height: 100%;
            font-weight: bold;
            font-size: 1.5em;
            line-height: 1.7em;
            color:#e6eb1a;
            background-color:#79489c;
        }
    </style>
</head>
<body>
    <div id="container">
        <div id="message">
            ${message}
        </div>
        <div id="messageButton">
            <button onclick="location.href='/views/index.html'">Ok</button>
        </div>
    </div>
</body>
</html>
