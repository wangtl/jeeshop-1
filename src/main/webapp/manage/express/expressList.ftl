<#import "/manage/tpl/pageBase.ftl" as page>
<@page.pageBase currentMenu="配送方式">
	<#--<form action="${basepath}/manage/express" method="post">-->
		<#--<table class="table table-bordered">-->
			<#--<tr>-->
				<#--<td colspan="8">-->
					<#--<button method="selectList" class="btn btn-primary" onclick="selectList(this)">-->
						<#--<i class="icon-search icon-white"></i> 查询-->
					<#--</button>-->
					<#---->
					<#--<a href="${basepath}/manage/express/toAdd" class="btn btn-success">-->
						<#--<i class="icon-plus-sign icon-white"></i> 添加-->
					<#--</a>-->
							<#---->
					<#--<button method="deletes" class="btn btn-danger" onclick="return submitIDs(this,'确定删除选择的记录?');">-->
						<#--<i class="icon-remove-sign icon-white"></i> 删除-->
					<#--</button>-->
							<#---->
					<#--<div style="float: right;vertical-align: middle;bottom: 0px;top: 10px;">-->
						<#--<#include "/manage/system/pager.ftl">-->
					<#--</div>-->
				<#--</td>-->
			<#--</tr>-->
		<#--</table>-->
		<#---->
		<#--<table class="table table-bordered table-hover">-->
			<#--<tr style="background-color: #dff0d8">-->
				<#--<th width="20"><input type="checkbox" id="firstCheckbox" /></th>-->
				<#--<th nowrap="nowrap">快递编码</th>-->
				<#--<th nowrap="nowrap">名称</th>-->
				<#--<th nowrap="nowrap">费用</th>-->
				<#--<th nowrap="nowrap">顺序</th>-->
				<#--<th style="width: 115px;">操作</th>-->
			<#--</tr>-->
			<#--<#list pager.list as item>-->
				<#--<tr>-->
					<#--<td><input type="checkbox" name="ids"-->
						<#--value="${item.id!""}" /></td>-->
					<#--<td nowrap="nowrap">&nbsp;${item.code!""}</td>-->
					<#--<td nowrap="nowrap">&nbsp;${item.name!""}</td>-->
					<#--<td nowrap="nowrap">&nbsp;${item.fee!""}</td>-->
					<#--<td nowrap="nowrap">&nbsp;${item.order1!""}</td>-->
					<#--<td nowrap="nowrap">-->
						<#--<a href="toEdit?id=${item.id!""}">编辑</a>-->
					<#--</td>-->
				<#--</tr></#list>-->
			<#--<tr>-->
				<#--<td colspan="16" style="text-align: center;">-->
					<#--<#include "/manage/system/pager.ftl">-->
				<#--</td>-->
			<#--</tr>-->
		<#--</table>-->
	<#--</form>-->


<form id="searchForm" class="form-horizontal" tabindex="0" style="outline: none;">
    <div class="row actions-bar">
        <div class="form-actions">

            <a href="${basepath}/manage/express/toAdd" class="btn btn-success">
                <i class="icon-plus-sign icon-white"></i> 添加
            </a>
		<a  class="btn btn-danger" onclick="return delFunction();">
			<i class="icon-remove-sign icon-white"></i> 删除
		</a>
        </div>
    </div>
</form>
<div id="grid"></div>

<script>
    var Grid = BUI.Grid,
            Store = BUI.Data.Store,
            columns = [
                {title : '快递编码',dataIndex :'code', width:100},
                {title : '名称',dataIndex :'name', width:100},
                {title : '费用',dataIndex : 'fee',width:100},
                {title : '顺序',dataIndex : 'order1',width:100},
                {title : '操作',dataIndex : 'id',width:200,renderer : function (value) {

					<#if checkPrivilege("/manage/user/edit")>
                        return '<a href="toEdit?id==' + value + '">编辑</a>';
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
                plugins : [Grid.Plugins.CheckSelection], // 插件形式引入多选表格
                // 底部工具栏
                bbar:{
                    pagingBar:true
                }
            });

    grid.render();


    //删除选中的记录
    function delFunction(){
        var selections = grid.getSelection();
        var ids=new Array();
        for(var i=0;i<selections.length;i++){
            ids[i]=selections[i].id.toString()
        }
        $.ajax({
            type: "POST",
            url: "${basepath}/manage/express/deletesJson",
            dataType: "json",
            data: {
                ids:ids
            },
            success: function (data) {
                var obj = new Object();
                obj.start = 0; //返回第一页
                store.load(obj);
            }
        });

    }


</script>

</@page.pageBase>