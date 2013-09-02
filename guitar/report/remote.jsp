<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" import="java.io.*"%>

<%
request.setCharacterEncoding("UTF-8");
String captureview = request.getParameter("captureview");
captureview=(captureview == null) ? "" : captureview;
%>


<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">

<script language="javascript">

function getCookie(name){
    var nameOfCookie = name + "=";
    var x = 0;
    while ( x <= document.cookie.length ){
        var y = (x+nameOfCookie.length);
        if ( document.cookie.substring( x, y ) == nameOfCookie ) {
            if ( (endOfCookie=document.cookie.indexOf( ";", y )) == -1 ) {
                endOfCookie = document.cookie.length;
            }
            return unescape( document.cookie.substring( y, endOfCookie ) );
        }
        x = document.cookie.indexOf( " ", x ) + 1;
        if ( x == 0 )
        break;
    }
    return "";
}



function setCookie (name, value) {
  var argv = setCookie.arguments;
  var argc = setCookie.arguments.length;
  var expires = (2 < argc) ? argv[2] : null;
  var path = (3 < argc) ? argv[3] : null;
  var domain = (4 < argc) ? argv[4] : null;
  var secure = (5 < argc) ? argv[5] : false;
  document.cookie　 = name + "=" + escape (value) +
      ((expires == null) ? "" :
        ("; expires=" + expires.toGMTString())) +
      ((path == null) ? "" : ("; path=" + path)) +
      ((domain == null) ? "" : ("; domain=" + domain)) +
      ((secure == true) ? "; secure" : "");
}

</script>

<script language="javascript">
 function goSubmit(cmd){
  var form = document.formMain;
  form.cmd.value = cmd;
  form.submit();
 }

function logview()

{

   frm.action = "confirm.jsp";
   frm.submit();

}

    	function captureview()
    	{
    	 var pwin=window.open('','winName','left=0,top=0,width=10,height=10,location=no,statusbar=no,scrollbars=yes,toolbar=no,resizable=yes');
    	 pwin.document.write("<html>");
    	 pwin.document.write("<body leftmargin=0 topmargin=0>");
    	 pwin.document.write("<img name='view' src='remote.png' contenteditable=false>");
    	 pwin.document.write("</body></html>");
    	 while(true)
    	 {
    	  if(pwin.document.all["view"].readyState=="complete")break;
    	 }
    	 pwin.resizeTo(pwin.document.body.scrollWidth, pwin.document.body.scrollHeight);
    	}
 </script>

${captureview}


<TITLE> GUITAR 원격관리 </TITLE>

<BODY style='font-family:dotum; font-size: 12px;' <%if(captureview.equals("on")){out.print("onload='captureview();'");}%>>

<h1>GUITAR 원격관리</h1>

<h2><a target='_dashboard' href='report.htm'>GUITAR 리포트</a></h2>

<hr>
<br>
<form name="formMain" method=post action="cmdrun.jsp">
<input type="hidden" value="" name="cmd">
스크립트 선택  : 목록 <input type="radio" name="scriptselect" value="c" checked>  <select name="script_c">
<%
try{
File f2 = new File(application.getRealPath("./lastrunscript.txt"));
FileReader fr2 = new FileReader(f2);
BufferedReader br2 = new BufferedReader(fr2); //버퍼리더객체생성
String line = null;
while((line=br2.readLine())!=null){ //라인단위 읽기

  out.print("<OPTION value='" + line +"'>" + line + "</OPTION><BR>" );
}
fr2.close();
}catch(Exception e){ }
%>
</select>  &nbsp;&nbsp; 	수동<input type="radio" name="scriptselect" value="m"> <input type="text" name="script"  onfocus="document.formMain.scriptselect[1].checked='true';"><br>
<br>
<input type="button"   style="height:33px;width:115px;" value="테스트 실행" onClick="goSubmit('run');"> &nbsp;&nbsp;
<input type="button"  style="height:33px;width:115px;" value="테스트 로그 보기" onClick="window.open('logview.jsp','_logview');"> &nbsp;&nbsp;
<input type="button" style="height:33px;width:115px;" value="테스트 중지 요청" onClick="goSubmit('stop');"> &nbsp;&nbsp;
<input type="button" style="height:33px;width:115px;" value="테스트 강제 종료" onClick="goSubmit('end');"> &nbsp;&nbsp;

<input type="button" style="height:33px;width:115px;" value="현재화면 보기" onClick="goSubmit('capture');"> &nbsp;&nbsp;
<input type="button" style="height:33px;width:115px;" value="새로고침" onClick="top.location.href='remote.jsp';"> &nbsp;&nbsp;
</form>
<br>
<hr>
<br>
원격 실행 로그
<br>
<br>
<%

try{
    File f = new File(application.getRealPath("./remote.log"));
    FileReader fr = new FileReader(f);
    StringBuffer sb = new StringBuffer();
    int ch = 0;

    while((ch = fr.read()) != -1){
        sb.append((char)ch);
    }
    fr.close();
    out.print("<xmp>" + sb.toString() + "</xmp>");
}catch(Exception e){ }
%>
<hr>
</body>
</html>