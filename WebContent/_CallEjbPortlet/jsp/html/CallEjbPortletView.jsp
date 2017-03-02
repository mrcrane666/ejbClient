<%@page session="false" contentType="text/html"
	pageEncoding="ISO-8859-1"
	import="java.util.*,javax.portlet.*,com.ibm.callejbportlet.*"%>
<%@ taglib uri="http://java.sun.com/portlet_2_0" prefix="portlet"%>
<%@taglib
	uri="http://www.ibm.com/xmlns/prod/websphere/portal/v6.1/portlet-client-model"
	prefix="portlet-client-model"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
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


<h5 style="color: red;">${errMessage}</h5>
<fieldset class="chatBoxFieldset">
	<div class="chatBox" id="messageField">
		<c:forEach var="message" items="${messages}">
		${message}<br>
		</c:forEach>
	</div>
</fieldset>
<form action="${sendMessage}">
	<input type="text" name="messageToSend">
	<button>Send Message</button>
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
				for (var i = 0; i < messages.length; i++) {
					allMessages = allMessages + messages[i] + "<br>";
				}
				$("#messageField").html(allMessages);
			},
			error : function(xhr, error, errorThrown) {
				alert(xhr.responseText);
				clearInterval(intervalID);
			}

		});

	}
</script>