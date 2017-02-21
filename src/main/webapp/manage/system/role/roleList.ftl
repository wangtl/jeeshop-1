<#import "/manage/tpl/pageBase.ftl" as page>
<@page.pageBase currentMenu="角色管理">
<#--<script type="text/javascript">-->
<#--$(function(){-->
	<#--$("#result_table tr").mouseover(function(){-->
		<#--$(this).addClass("over");}).mouseout(function(){-->
		<#--$(this).removeClass("over");});-->
	<#---->
	<#--//全选、反选-->
	<#--$("#checkAll").click(function() {-->
        <#--$('input[type=checkbox]').attr("checked",$(this).attr("checked")?true:false); -->
    <#--});-->
<#--});-->
<#--function deleteSelect(){-->
	<#--if($("input:checked").size()==0){-->
		<#--return false;-->
	<#--}-->
	<#--return confirm("确定删除选择的记录?");-->
<#--}-->
<#--</script>-->

<#--<form action="${basepath}/manage/role"  method="post">-->
			<#--<table class="table table-bordered">-->
				<#--<tr  >-->
					<#--<td>-->
                        <#--<#if checkPrivilege("role/insert")>-->
							<#--<a href="${basepath}/manage/role/toAdd" class="btn btn-success">-->
								<#--<i class="icon-plus-sign icon-white"></i> 添加-->
							<#--</a>-->
                        <#--</#if>-->
					<#--</td>-->
				<#--</tr>-->
			<#--</table>-->
			<#---->
			<#--<table class="table table-bordered table-hover">-->
				<#--<tr style="background-color: #dff0d8">-->
					<#--<th width="20">-->
						<#--<input type="checkbox" id="checkAll"/>-->
					<#--</th>-->
					<#--<th  style="display: none;">rid</th>-->
					<#--<th>角色名称</th>-->
					<#--<th>角色描述</th>-->
					<#--<th>数据库权限</th>-->
					<#--<th>状态</th>-->
					<#--<th width="50px">操作</th>-->
				<#--</tr>-->
                <#--<#list pager.list as item>-->
					<#--<tr>-->
						<#--<td><#if item.id!=1><input type="checkbox" name="ids" value="${item.id}/>"/></#if></td>-->
						<#--<td  style="display: none;">&nbsp;${item.rid!""}</td>-->
						<#--<td>&nbsp;${item.role_name!""}</td>-->
						<#--<td>&nbsp;${item.role_desc!""}</td>-->
						<#--<td>&nbsp;${item.role_dbPrivilege!""}</td>-->
						<#--<td>&nbsp;-->
							<#--<#if item.status=="y">-->
								<#--<img alt="显示" src="${basepath}/resource/images/action_check.gif">-->
							<#--<#else>-->
								<#--<img alt="不显示" src="${basepath}/resource/images/action_delete.gif">-->
							<#--</#if>-->
						<#--</td>-->
						<#--<td>-->
							<#--<!-- 系统角色只能是超级管理员编辑 &ndash;&gt;-->
                            <#--<#if currentUser().username == "admin">-->
								<#--<a href="${basepath}/manage/role/toEdit?id=${item.id}">编辑</a>-->
                            <#--</#if>-->
						<#--</td>-->
					<#--</tr>-->
                <#--</#list>-->
				<#--<tr>-->
								<#--<td colspan="15" style="text-align:center;">-->
                                    <#--<#include "/manage/system/pager.ftl"/>-->
								<#--</td>-->
							<#--</tr>-->
			<#--</table>-->
    <#--</form>-->


<form id="searchForm" class="form-horizontal" tabindex="0" style="outline: none;">
    <div class="row actions-bar">
        <div class="form-actions">
			<#if checkPrivilege("role/insert")>
                <a href="${basepath}/manage/role/toAdd" class="btn btn-success"><i class="icon-plus-sign icon-white"></i> 添加</a>
			</#if>
        </div>
    </div>
</form>
<div id="grid"></div>

<script>
    var Grid = BUI.Grid,
            Store = BUI.Data.Store,
            columns = [
                {title : '角色名称',dataIndex :'role_name', width:100},
                {title : '角色描述',dataIndex :'role_desc', width:100},
                {title : '数据库权限',dataIndex : 'role_dbPrivilege',width:100},
                {title : '状态',dataIndex : 'status',width:100, renderer:function(data){
                    if(data == "y"){
                        return '<img src="${basepath}/resource/images/action_check.gif">';
                    } else {
                        return '<img src="${basepath}/resource/images/action_delete.gif">';
                    }
                }},
                {title : '操作',dataIndex : 'id',width:200,renderer : function (value) {

					<#if currentUser().username == "admin">
                        return '<a href="${basepath}/manage/role/toEdit?id=' + value + '">编辑</a>';
					<#else>
                        return "";
					</#if>


                }}
            ];

    var store = new Store({
                url : 'loadData',
                autoLoad:true, //自动加载数据
                params : { //配置初始请求的参数
                    length : '10',
                    status:$("#status").val()
                },
                pageSize:3,	// 配置分页数目
                root : 'list',
                totalProperty : 'total'
            }),
            grid = new Grid.Grid({
                render:'#grid',
                columns : columns,
                loadMask: true, //加载数据时显示屏蔽层
                store: store,
                // 底部工具栏
                bbar:{
                    pagingBar:true
                }
            });

    grid.render();

    var form = new BUI.Form.HForm({
        srcNode : '#searchForm'
    }).render();

    form.on('beforesubmit',function(ev) {
        //序列化成对象
        var obj = form.serializeToObject();
        obj.start = 0; //返回第一页
        store.load(obj);
        return false;
    });
</script>


</@page.pageBase>