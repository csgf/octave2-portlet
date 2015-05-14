<%
/**
 * Copyright (c) 2000-2011 Liferay, Inc. All rights reserved.
 *
 * This library is free software; you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License as published by the Free
 * Software Foundation; either version 2.1 of the License, or (at your option)
 * any later version.
 *
 * This library is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
 * details.
 */
%>

<%@ page import="com.liferay.portal.kernel.util.WebKeys" %>
<%@ page import="com.liferay.portal.util.PortalUtil" %>
<%@ page import="com.liferay.portal.model.Company" %>
<%@ page import="javax.portlet.*" %>
<%@ taglib uri="http://java.sun.com/portlet_2_0" prefix="portlet" %>
<%@ taglib uri="http://liferay.com/tld/theme" prefix="liferay-theme" %>
<%@ taglib uri="http://liferay.com/tld/ui" prefix="liferay-ui" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>

<portlet:defineObjects />
<%//
  // Octave input form
  // 
  // The ohter three buttons of the form are used for:
  //    o Demo:          Used to fill with demo values the text areas
  //    o SUBMIT:        Used to execute the job on the eInfrastructure
  //    o Reset values:  Used to reset input fields
  //  
%>

<%
// Below the descriptive area of the GATE web form 
%>
<table>
<tr>
<td valign="top">
<img align="left" style="padding:10px 10px;" src="<%=renderRequest.getContextPath()%>/images/AppLogo.png" />
</td>
<td>
<p>
<a href="http://www.gnu.org/software/octave/">GNU Octave</a> is a high-level interpreted language, primarily intended for numerical computations. It provides capabilities for the numerical solution of linear and nonlinear problems, and for performing other numerical experiments.</p>
<center><img src="http://www.gnu.org/software/octave/images/screenshot-small.png"/></center>
You may upload your macro file or directly type the code into the TextArea below. Then press <b>'SUBMIT'</b> button to launch Octave application into a distributed infrastructure.<br>
Requested inputs are:
<ul>
	<li>An input file (a Macro file to upload)</li>
        <li>Otherwise type your macro code inside the text area.</li>
</ul>
Pressing the <b>'Demo'</b> Button input fields will be filled with Demo values.<br>
Pressing the <b>'Reset'</b> Button all input fields will be initialized.<br>
Pressing the <b>'About'</b> Button information about the application will be shown
</td>
<tr>
</table align="center">
<%
// Below the application submission web form 
//
// The <form> tag contains a portlet parameter value called 'PortletStatus' the value of this item
// will be read by the processAction portlet method which then assigns a proper view mode before
// the call to the doView method.
// PortletStatus values can range accordingly to values defined into Enum type: Actions
// The processAction method will assign a view mode accordingly to the values defined into
// the Enum type: Views. This value will be assigned calling the function: setRenderParameter
//
%>
<center>
<form enctype="multipart/form-data" action="<portlet:actionURL portletMode="view"><portlet:param name="PortletStatus" value="ACTION_SUBMIT"/></portlet:actionURL>" method="post">
<dl>	
	<!-- This block contains: label, file input and textarea for GATE Macro file -->
	<dd>		
 		<p><b>Application' input file</b> <input type="file" name="file_inputFile" id="upload_inputFileId" accept="*.*" onchange="uploadInputFile()"/></p>
		<textarea id="inputFileId" rows="20" cols="100%" name="inputFile">Insert here your text file, or upload a macro file</textarea>
	</dd>
	<!-- This block contains the experiment name -->
	<dd>
		<p>Insert below your <b>job identifyer</b></p>
		<textarea id="jobIdentifierId" rows="1" cols="60%" name="JobIdentifier">Octave execution ...</textarea>
	</dd>	
	<!-- This block contains form buttons: Demo, SUBMIT and Reset values -->
  	<dd>
  		<td><input type="button" value="Demo" onClick="addDemo()"></td>
  		<td><input type="button" value="Submit" onClick="preSubmit()"></td> 
  		<td><input type="reset" value="Reset values" onClick="resetForm()"></td>
  	</dd>
</dl>
</form>
   <tr>
        <form action="<portlet:actionURL portletMode="HELP"> /></portlet:actionURL>" method="post">
        <td><input type="submit" value="About"></td>
        </form>        
   </tr>
</table>
</center>

<%
// Below the javascript functions used by the GATE web form 
%>
<script type="text/javascript">
//
// preSubmit
//
function preSubmit() {  
    var inputFileName=document.getElementById('upload_inputFileId');
    var inputFileText=document.getElementById('inputFileId');
    var jobIdentifier=document.getElementById('jobIdentifierId');
    var state_inputFileName=false;
    var state_inputFileText=false;
    var state_jobIdentifier=false;
    
    if(inputFileName.value=="") state_inputFileName=true;
    if(inputFileText.value=="" || inputFileText.value=="Insert here your text file, or upload a file") state_inputFileText=true;
    if(jobIdentifier.value=="") state_jobIdentifier=true;    
       
    var missingFields="";
    if(state_inputFileName && state_inputFileText) missingFields+="  Input file or Text message\n";
    if(state_jobIdentifier) missingFields+="  Job identifier\n";
    if(missingFields == "") {
      document.forms[0].submit();
    }
    else {
      alert("You cannot send an inconsistent job submission!\nMissing fields:\n"+missingFields);
        
    }
}
//
//  uploadMacroFile
//
// This function is responsible to disable the related textarea and 
// inform the user that the selected input file will be used
function uploadInputFile() {
	var inputFileName=document.getElementById('upload_inputFileId');
	var inputFileText=document.getElementById('inputFileId');
	if(inputFileName.value!='') {
		inputFileText.disabled=true;
		inputFileText.value="Using file: '"+inputFileName.value+"'";
	}
}

//
//  resetForm
//
// This function is responsible to enable all textareas
// when the user press the 'reset' form button
function resetForm() {
	var currentTime = new Date();
	var inputFileName=document.getElementById('upload_inputFileId');
	var inputFileText=document.getElementById('inputFileId');
	var jobIdentifier=document.getElementById('jobIdentifierId');
        
        // Enable the textareas
	inputFileText.disabled=false;
	inputFileName.disabled=false;        			
            
	// Reset the job identifier
        jobIdentifier.value="Octave execution ...";
}

//
//  addDemo
//
// This function is responsible to enable all textareas
// when the user press the 'reset' form button
function addDemo() {
	var currentTime = new Date();
	var inputFileName=document.getElementById('upload_inputFileId');
	var inputFileText=document.getElementById('inputFileId');
	var jobIdentifier=document.getElementById('jobIdentifierId');
	
	// Disable all input files
        inputFileText.disabled=false;
	inputFileName.disabled=true;
	
	// Secify that the simulation is a demo
	jobIdentifier.value="Octave demo execution";
	
        // Add the demo value for the GATE macro file
	// Old demo (text only):
        //inputFileText.value="A = [ 1, 1, 2; 3, 5, 8; 13, 21, 34 ]"
        //              +"\n"+"B = [ 10, 0, 1; 3, 1, 1; 1, 2, 4 ]"
        //              +"\n"+"printf (\"A*B\\n\")"
        //              +"\n"+"A * B"
        //              +"\n"+"printf (\"A'*A\\n\")"
        //              +"\n"+"A' * A"
        //              +"\n";
        // New demo (graphic output 'demo_output.eps')
	inputFileText.value=
                       "# -[Octave demo ]- \n"
                      +"# This is a macro demo that produces      \n"
                      +"# a simple bidimentional graph of the     \n"
                      +"# function: r=sqrt(x^2+y^2); sin(r)/r     \n"
                      +"# The output will be stored into an eps   \n"
                      +"# image file format.                      \n"
                      +"#                                         \n"
                      +"# The image file will be available inside \n"
                      +"# the compressedi job ouput file (tar.gz) \n"
                      +"# \n"
                      +"tx = ty = linspace (-8, 8, 41)';"
                      +"\n"+"[xx, yy] = meshgrid (tx, ty);"
                      +"\n"+"r = sqrt (xx .^ 2 + yy .^ 2) + eps;"
                      +"\n"+"tz = sin (r) ./ r;"
                      +"\n"+"mesh (tx, ty, tz);"
                      +"\n"+"print -deps demo_output.eps";
}
</script>
