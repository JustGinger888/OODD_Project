<%-- 
    Document   : Gate
    Created on : 18 Dec 2020, 23:50:35
    Author     : ethan
--%>

<%@page import="java.io.StringReader"%>
<%@page import="javax.xml.bind.Unmarshaller"%>
<%@page import="org.solent.com528.project.model.dto.Station"%>
<%@page import="java.util.List"%>
<%@page import="org.solent.com528.project.impl.webclient.WebClientObjectFactory"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.Set"%>
<%@page import="org.solent.com528.project.model.dao.StationDAO"%>
<%@page import="org.solent.com528.project.model.service.ServiceFacade"%>
<%@page import="java.util.Calendar"%>
<%@page import="org.solent.com528.project.clientservice.impl.TicketEncoderImpl"%>
<%@page import="org.solent.com528.project.model.dto.Ticket"%>
<%@page import="org.solent.com528.project.model.dto.CreditCardValidityCalculator"%>
<%@page import="org.solent.com528.project.model.dto.Rate"%>
<%@page import="org.solent.com528.project.impl.dao.jaxb.PriceCalculatorDAOJaxbImpl"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%@page import="java.text.DateFormat"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>

<%@page import="javax.xml.bind.JAXBContext"%>
<%@page import="java.io.StringWriter"%>
<%@page import="javax.xml.bind.Marshaller"%>

<%
    String errorMessage = "";
    Date currentTimeStr = new Date();
    String ticketStr = request.getParameter("ticketStr");
    response.setIntHeader("Refresh", 69);
    Date issueDate = null;
    String destinationSation = null;
    boolean validDateTime = false;
    boolean validFormat = false;
    boolean validStation = false;    
    boolean valid = false;
    
    String destinationStationName = request.getParameter("destinationStationName");

    ServiceFacade serviceFacade = (ServiceFacade) WebClientObjectFactory.getServiceFacade();

    // ZONES AND STATION
    // accessing service 
    StationDAO stationDAO = serviceFacade.getStationDAO();
    Set<Integer> zones = stationDAO.getAllZones();
    List<Station> stationList = new ArrayList<Station>();

    // accessing request parameters
    String actionStr = request.getParameter("action");
    String zoneStr = request.getParameter("zone");

    // return station list for zone
    if (zoneStr == null || zoneStr.isEmpty()) {
        stationList = stationDAO.findAll();
    } else {
        try {
            Integer zone = Integer.parseInt(zoneStr);
            stationList = stationDAO.findByZone(zone);
        } catch (Exception ex) {
            errorMessage = ex.getMessage();
        }
    }

    // basic error checking before making a call
    if (actionStr == null || actionStr.isEmpty()) {
        // do nothing

    } else if ("XXX".equals(actionStr)) {
        // put your actions here
    } else {
        errorMessage = "ERROR: page called for unknown action";
    }
    // ZONES AND STATION

    if (ticketStr != null) {
        try {
            //  but allows for refactoring
            JAXBContext jaxbContext = JAXBContext.newInstance("org.solent.com528.project.model.dto");
            Unmarshaller jaxbUnMarshaller = jaxbContext.createUnmarshaller();
            Ticket ticket = (Ticket) jaxbUnMarshaller.unmarshal(new StringReader(ticketStr));
            issueDate = ticket.getIssueDate();
            destinationSation = ticket.getEndStation();
        } catch (Exception ex) {
            throw new IllegalArgumentException("could not marshall to Ticket ticketXML=" + ticketStr);
        }
    }

    try {
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(issueDate);
        calendar.add(Calendar.HOUR_OF_DAY, 24);
        validDateTime = currentTimeStr.before(calendar.getTime());
    } catch (Exception e) {
    }

    validFormat = TicketEncoderImpl.validateTicket(ticketStr);

    try {

        validStation = destinationStationName.equals(destinationSation);

    } catch (Exception e) {
    }
    

    if (validDateTime && validFormat && validStation) {
        valid = true;
    } else {
        valid = false ;
    }


%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Open gate</title>
    </head>
    <body>
        <h1><a href="./">Open Gate with Ticket</a></h1>
        <!-- print error message if there is one -->
        <div style="color:red;"><%=errorMessage%></div>
        <form action="./ticketGate.jsp"  method="post" >
            <table>
                <tr>
                    <td>Valid Format:</td>
                    <td>
                        <p><%=validFormat%></p>
                    </td>
                </tr>
                <tr>
                    <td>Valid Date</td>
                    <td>
                        <p><%=validDateTime%></p>
                    </td>
                </tr>
                <tr>
                    <td>Valid Station</td>
                    <td>
                        <p><%=validStation%></p>
                    </td>
                </tr>

                <tr>
                    <td>
                        Arrival Zone:
                    </td>
                    <td>
                        <%
                            for (Integer selectZone : zones) {
                        %>
                        <form action="./ticketGate.jsp" method="get">
                            <input type="hidden" name="zone" value="<%= selectZone%>">
                            <button type="submit" >Zone&nbsp;<%= selectZone%></button>
                        </form> 
                        <%
                            }
                        %>

                        </select>
                    </td>
                </tr>
                <tr>
                    <td>Arrival Station:</td>
                    <td>
                        <select name="destinationStationName" id="destinationStationName">
                            <%
                                for (Station station : stationList) {
                            %>
                            <option value="<%=station.getName()%>"><%=station.getName()%></option>
                            <%
                                }
                            %>
                    </td>
                </tr>


        </form> 


    <tr>
        <td>Current Time</td>
        <td>
            <p><%= currentTimeStr.toString()%> (note page is auto refreshed every 69 seconds)</p>
        </td>
    </tr>
    <tr>
        <td>Ticket Data:</td>
        <td><textarea name="ticketStr" rows="14" cols="120"><%=ticketStr%></textarea></td>
    </tr>
</table>
<button type="submit" >Open Gate</button>
</form> 
<BR>
<% if (valid) { %>
<div style="color:green;font-size:x-large">GATE OPEN</div>
<%  } else {  %>
<div style="color:red;font-size:x-large">GATE LOCKED</div>
<% }%>
</body>
</html>
