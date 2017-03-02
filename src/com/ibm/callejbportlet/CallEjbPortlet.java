package com.ibm.callejbportlet;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Properties;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.portlet.ActionRequest;
import javax.portlet.ActionResponse;
import javax.portlet.GenericPortlet;
import javax.portlet.PortletException;
import javax.portlet.PortletRequestDispatcher;
import javax.portlet.ProcessAction;
import javax.portlet.RenderMode;
import javax.portlet.RenderRequest;
import javax.portlet.RenderResponse;
import javax.portlet.ResourceRequest;
import javax.portlet.ResourceResponse;
import javax.rmi.PortableRemoteObject;

import org.codehaus.jackson.map.JsonSerializer;

import com.google.gson.Gson;
import com.ibm.json.java.JSONArray;
import com.ibm.lang.management.SysinfoCpuTime;
import com.ibm.wps.model.controller.impl.Observable;

import ejb.test.ChatInterface;
import ejb.test.RemoteInterface;

/**
 * A sample portlet based on GenericPortlet
 */
public class CallEjbPortlet extends GenericPortlet {

	public static final String JSP_FOLDER = "/_CallEjbPortlet/jsp/";
	public static final String VIEW_JSP = "CallEjbPortletView";
	public static final String SESSION_BEAN = "CallEjbPortletSessionBean";
	public static final String FORM_SUBMIT = "CallEjbPortletFormSubmit";
	public static final String FORM_TEXT = "CallEjbPortletFormText";
	public ChatInterface chat;

	public void init() throws PortletException {
		super.init();
		Properties props = new Properties();
		props.put(Context.INITIAL_CONTEXT_FACTORY,
				"com.ibm.websphere.naming.WsnInitialContextFactory");
		InitialContext ctx;
		Object objref2 = null;
		try {
			ctx = new InitialContext(props);
			objref2 = ctx.lookup("java:comp/env/ejb/chat");
		} catch (NamingException e) {
			e.printStackTrace();
		}

		chat = (ChatInterface) PortableRemoteObject.narrow(objref2,
				ChatInterface.class);
	}

	public void doView(RenderRequest request, RenderResponse response)
			throws PortletException, IOException {
		String err = chat.getErrMessage();
		if (err.equals("")) {
			request.setAttribute("messages", chat.getMessages());
			System.out.println(request.getUserPrincipal());
			request.setAttribute("user", request.getUserPrincipal());
		}else{
			request.setAttribute("errMessage", err);
			request.setAttribute("messages", chat.getMessages());
		}
		
		response.setContentType(request.getResponseContentType());
		PortletRequestDispatcher rd = getPortletContext().getRequestDispatcher(
				getJspFilePath(request, VIEW_JSP));
		rd.include(request, response);
	}

	@ProcessAction(name = "sendMessage")
	public void sendMessage(ActionRequest req, ActionResponse res) {
		Calendar cal = Calendar.getInstance();
		SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss");
		chat.addMessage(req.getUserPrincipal().getName(),
				sdf.format(cal.getTime()), req.getParameter("messageToSend"));
	}

	@ProcessAction(name = "resetMessages")
	public void resetMessages(ActionRequest req, ActionResponse res) {
		chat.resetMessages();
	}

	public void serveResource(ResourceRequest request, ResourceResponse response)
			throws PortletException, java.io.IOException {
		Gson gson = new Gson();
		response.resetBuffer();
		response.getWriter().print(gson.toJson(chat.getMessages()));
		response.flushBuffer();
	}

	private static String getJspFilePath(RenderRequest request, String jspFile) {
		String markup = request.getProperty("wps.markup");
		if (markup == null)
			markup = getMarkup(request.getResponseContentType());
		return JSP_FOLDER + markup + "/" + jspFile + "."
				+ getJspExtension(markup);
	}

	private static String getMarkup(String contentType) {
		if ("text/vnd.wap.wml".equals(contentType))
			return "wml";
		else
			return "html";
	}

	private static String getJspExtension(String markupName) {
		return "jsp";
	}

}
