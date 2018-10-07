package fr.pocia;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;

// Extend HttpServlet class
public class HelloWorldServlet extends HttpServlet {
 
   private String message;

   public void init() throws ServletException {
      // Do required initialization
      message = "Hello World you said ";
   }

   public void doGet(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
      
      // Set response content type
      response.setContentType("text/html");

      // Actual logic goes here.
      PrintWriter out = response.getWriter();
      String info = request.getPathInfo();
      out.println("<h1><i>" + message + info + "</i></h1>");
      //write in /usr/tomcat/data
      touch(new File("/usr/tomcat/data1",info));      
   }

   public void destroy() {
      // do nothing.
   }

   public static void touch(File file) throws IOException{
     long timestamp = System.currentTimeMillis();
     touch(file, timestamp);
   }

   public static void touch(File file, long timestamp) throws IOException{
      if (!file.exists()) {
         new FileOutputStream(file).close();
       }

    file.setLastModified(timestamp);
   }
}
