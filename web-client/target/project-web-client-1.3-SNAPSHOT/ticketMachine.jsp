<%-- 
    Document   : TicketMachien
    Created on : 18 Dec 2020, 23:20:40
    Author     : ethan
--%>

<%@page import="java.util.regex.Matcher"%>
<%@page import="java.util.regex.Pattern"%>
<%@page import="org.solent.com528.project.model.dao.PriceCalculatorDAO"%>
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
    // Getting and setting Initial values
    
    Ticket ticket = new Ticket();
    
    String startStationStr = request.getParameter("startStation");
    String endStationStr = request.getParameter("endStation");
    String ticketStr = request.getParameter("ticketStr");
    String paymentCard = request.getParameter("paymentCard");
    String destinationStationName = request.getParameter("destinationStationName");
    String errorMessage = "";
    String currentTimeStr = new Date().toString();
    boolean validPayment = false;

    ServiceFacade serviceFacade = (ServiceFacade) WebClientObjectFactory.getServiceFacade();
    String startStationName = WebClientObjectFactory.getStationName();
    Integer startStationZone = WebClientObjectFactory.getStationZone();

    String endStationZone = request.getParameter("zone");

    CreditCardValidityCalculator cardValidityCalculator = new CreditCardValidityCalculator();

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
            errorMessage = "Please choose a Zone Number";
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

    // Assigning Pricing File to Calculator
    String fileName = "target/priceCalculatorDAOJaxbImplFile.xml";
    PriceCalculatorDAOJaxbImpl priceCalculatorDAOJaxb = new PriceCalculatorDAOJaxbImpl(fileName);

    // Calendar to determine expiration Time 
    Calendar calendar = Calendar.getInstance();
    calendar.setTime(new Date());
    calendar.add(Calendar.HOUR_OF_DAY, 24);
    String validToTimeStr = calendar.getTime().toString();

    // Calculating Price & Rate
    PriceCalculatorDAO pricecalculatorDAO = serviceFacade.getPriceCalculatorDAO();
    pricecalculatorDAO.getPricingDetails();
    double pricePerZone = pricecalculatorDAO.getPricePerZone(new Date());
    Rate rate = priceCalculatorDAOJaxb.getRate(new Date());
    int zonesTravelled = 1;
    int endZoneInt = 0;
    double ticketPrice = 0;
    try {
        endZoneInt = Integer.parseInt(endStationZone);
        zonesTravelled = Math.abs(startStationZone - endZoneInt);
        if (zonesTravelled == 0) {
                zonesTravelled = 1;
            } 
        ticketPrice = pricePerZone * zonesTravelled;
        ticket.setCost(ticketPrice);
    } catch (Exception e) {
    }

    
    
    // Creating The Ticket Boio
    ticket.setStartStation(startStationName);
    ticket.setIssueDate(new Date());
    ticket.setRate(rate);
    ticket.setEndStation(destinationStationName);;

    // Creting the encoded ticket boio
    String encodedTicketStr = TicketEncoderImpl.encodeTicket(ticket);

    // use regex to validate card
    String regex = "^(?:(?<visa>4[0-9]{12}(?:[0-9]{3})?)|" +
        "(?<mastercard>5[1-5][0-9]{14})|" +
        "(?<discover>6(?:011|5[0-9]{2})[0-9]{12})|" +
        "(?<amex>3[47][0-9]{13})|" +
        "(?<diners>3(?:0[0-5]|[68][0-9])?[0-9]{11})|" +
        "(?<jcb>(?:2131|1800|35[0-9]{3})[0-9]{11}))$";
    
    try {
            
        
    Pattern pattern = Pattern.compile(regex);
    Matcher matcher = pattern.matcher(paymentCard);
     if(matcher.matches()) {
    
    ticketStr = encodedTicketStr;
    }
    }catch (Exception e) {
        }

%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Manage gate Locks</title>
    </head>
    <body>
        <h1><a href="./">Generate a New Ticket</a></h1>
        <!-- print error message if there is one -->
        <div style="color:red;"><%=errorMessage%></div>

        <form action="./ticketMachine.jsp?zone=<%= endZoneInt%>"  method="post">
            <table>
                <tr>
                    <td>Start Zones:</td>
                    <td><%=startStationZone%></td>
                </tr>
                <tr>
                    <td>Starting Station:</td>
                    <td><%=startStationName%></td>
                </tr>

                <tr>
                    <td>
                        Destination Zone:
                    </td>
                    <td>
                        <%
                            for (Integer selectZone : zones) {
                        %>
                        <form action="./ticketMachine.jsp" method="get">
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
                    <td>Destination Zone:</td>
                    <td><%= endZoneInt%></td>
                </tr>
                <tr>
                    <td>Destination Station:</td>
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
                <tr>
                    <td>Credit Card:</td>
                    <td><input type="text" name="paymentCard" value="<%=paymentCard%>"></td>
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
                <tr>
                    <td>Ticket Cost:</td>
                    <td>
                        <p><%=ticketPrice%></p>
                    </td>
                </tr>
            </table>
            <button type="submit" >Create Ticket</button>
        </form> 
        <h1>generated ticket XML</h1>
        <textarea id="ticketTextArea" rows="14" cols="120"><%=ticketStr%></textarea>

    </body>
</html>
