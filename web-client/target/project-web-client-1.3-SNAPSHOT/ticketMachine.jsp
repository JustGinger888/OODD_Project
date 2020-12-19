<%-- 
    Document   : TicketMachien
    Created on : 18 Dec 2020, 23:20:40
    Author     : ethan
--%>

<%@page import="java.util.Calendar"%>
<%@page import="org.solent.com528.project.clientservice.impl.TicketEncoderImpl"%>
<%@page import="org.solent.com528.project.model.dto.Ticket"%>
<%@page import="org.solent.com528.project.model.dto.Rate"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@page import="java.text.DateFormat"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>

<%@page import="javax.xml.bind.JAXBContext"%>
<%@page import="java.io.StringWriter"%>
<%@page import="javax.xml.bind.Marshaller"%>

<%

    String validFromStr = request.getParameter("validFrom");

    String validToStr = request.getParameter("validTo");
    
    String zonesStr = request.getParameter("zones");
    
    String startStationStr = request.getParameter("startStation");

    String errorMessage = "";
    String currentTimeStr = new Date().toString();
    
    Calendar calendar = Calendar.getInstance();
    calendar.setTime(new Date());
    calendar.add(Calendar.HOUR_OF_DAY, 24);
    String validToTimeStr = calendar.getTime().toString();
    
    String ticketStr = request.getParameter("ticketStr");
    
    Ticket ticket = new Ticket();
    ticket.setCost(5.50);
    ticket.setStartStation("startStation");
    ticket.setIssueDate(new Date());
    ticket.setRate(Rate.PEAK);

    String encodedTicketStr = TicketEncoderImpl.encodeTicket(ticket);

    ticketStr = encodedTicketStr;

%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Manage gate Locks</title>
    </head>
    <body>
        <h1>Generate a New Ticket</h1>
        <!-- print error message if there is one -->
        <div style="color:red;"><%=errorMessage%></div>

        <form action="./ticketMachine.jsp"  method="post">
            <table>
                <tr>
                    <td>Zones:</td>
                    <td><input type="text" name="zones" value="<%=zonesStr%>"></td>
                </tr>
                <tr>
                    <td>Starting Station:</td>
                    <td><input type="text" name="startStation" value="<%=startStationStr%>"></td>
                </tr>
                <tr>
                    <td>Valid From Time:</td>
                    <td>
                        <p><%=currentTimeStr%></p>
                    </td>
                </tr>
                <tr>
                    <td>Valid To Time:</td>
                    <td>
                        <p><%=validToTimeStr%></p>
                    </td>
                </tr>
            </table>
            <button type="submit" >Create Ticket</button>
        </form> 
        <h1>generated ticket XML</h1>
        <textarea id="ticketTextArea" rows="10" cols="120"><%=ticketStr%></textarea>

    </body>
</html>
