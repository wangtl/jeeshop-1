<#--该页面废弃-->
<#import "/manage/tpl/htmlBase.ftl" as html />
<@html.htmlBase>
<frameset cols="210,*" >
	<frame src="${basepath}/forward.action?p=/manage/system/left" name="leftFrame" noresize="noresize"/>
	<frame src="${basepath}/manage/user/initManageIndex" name="rightFrame" />
</frameset>
</@html.htmlBase>
