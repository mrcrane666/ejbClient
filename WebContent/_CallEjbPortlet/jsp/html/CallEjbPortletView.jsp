<%@page session="false" contentType="text/html"
	pageEncoding="ISO-8859-1"
	import="java.util.*,javax.portlet.*,com.ibm.callejbportlet.*"%>
<%@ taglib uri="http://java.sun.com/portlet_2_0" prefix="portlet"%>
<%@taglib
	uri="http://www.ibm.com/xmlns/prod/websphere/portal/v6.1/portlet-client-model"
	prefix="portlet-client-model"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn"%>

<portlet:defineObjects />
<portlet-client-model:init>
	<portlet-client-model:require module="ibm.portal.xml.*" />
	<portlet-client-model:require module="ibm.portal.portlet.*" />
</portlet-client-model:init>
<portlet:actionURL name="sendMessage" var="sendMessage"></portlet:actionURL>
<portlet:actionURL name="resetMessages" var="resetMessages"></portlet:actionURL>
<portlet:resourceURL var="refreshMessages" id="refreshMessages"></portlet:resourceURL>
<link rel="stylesheet" href="<c:url value="/res/css/Chat.css" />">

<script type="text/javascript"
	src='<c:url value="/res/js/general/jquery-3.1.1.min.js" />'>
	
</script>
<c:if test="${user != null}">
	<h4>Hello ${user}!</h4>
</c:if>
<h5 style="color: red;">${errMessage}</h5>
<fieldset class="chatBoxFieldset">
	<div class="chatBox" id="messageField">
		<c:if test="${user == null}">No recent messages.</c:if>
		<c:forEach var="message" items="${messages}">
			<c:if test="${fn:startsWith(message,'/')}">
				<c:if
					test='${user eq message.substring(1,fn:indexOf(message, "&"))}'>
					<div style="color: blue">
						(Private) ${message.substring(fn:indexOf(message, "&")+1, message.length())}<br>
					</div>
				</c:if>
			</c:if>
			<c:if test="${not fn:startsWith(message,'/')}">(Public) ${message }<br></c:if>
		</c:forEach>
	</div>
</fieldset>
<form action="${sendMessage}">
	<c:if test="${user != null}">
		<input type="text" name="messageToSend">
		<button>Send Message</button>
	</c:if>
	<c:if test="${user == null}">
		<input disabled="disabled" type="text" name="messageToSend">
		<button disabled="disabled">Send Message</button>
	</c:if>

	<a href="${resetMessages}">Reset Messages</a>
</form>
<form id="refreshSite" action="${refreshMessages}" hidden="true"></form>
<script type="text/javascript">
	var intervalID;
	window.onload = function() {
		intervalID = setInterval(callAjax, 2000);
	}
	function callAjax() {
		$.ajax({
			url : '${refreshMessages}',
			type : 'GET',
			datatype : "json",
			success : function(data) {
				var messages = JSON.parse(data);
				var allMessages = "";
				var user = messages[0];
				for (var i = 1; i < messages.length; i++) {
					var tmp = messages[i];
					if (tmp.substring(0, 1) == ("/")) {
						if (tmp.substring(1, tmp.indexOf('&')) === user) {
							var privateMessage = tmp.substring(
									tmp.indexOf('&') + 1, tmp.length);
							allMessages = allMessages
									+ "<div style='color: blue'>(Private) "
									+ privateMessage + "<br></div>";
						}
					}

					else {
						allMessages = allMessages + "(Public) " + tmp + "<br>";
					}

				}
				if (messages == "") {
					$("#messageField").html("No recent messages.");
				} else {
					$("#messageField").html(allMessages);
				}

			},
			error : function(xhr, error, errorThrown) {
				alert("Failed to recive messages!")
				clearInterval(intervalID);
			}

		});
	}
</script>