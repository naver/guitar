<%@ page contentType="text/html; charset=euc-kr" import="java.io.*"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<title>UIA Testing Log</title>

<body>
<%
    File f = new File(application.getRealPath("./running.log"));

    FileReader fr = new FileReader(f);
    StringBuffer sb = new StringBuffer();
    
    BufferedReader br = new BufferedReader(fr); 
	
    String str = null;
	while (null != (str = br.readLine())) {		
	
		sb.insert(0,str + "\r\n");
    }
    fr.close();
    
    out.print("<xmp>" + sb.toString() + "</xmp>");
%>
 
</body>
</html>



