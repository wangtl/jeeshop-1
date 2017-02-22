<#import "/manage/tpl/pageTep.ftl" as page>
<@page.pageBase currentMenu="键值对管理">
<#--<style type="text/css">-->
<#--.titleCss {-->
	<#--background-color: #e6e6e6;-->
	<#--border: solid 1px #e6e6e6;-->
	<#--position: relative;-->
	<#--margin: -1px 0 0 0;-->
	<#--line-height: 32px;-->
	<#--text-align: left;-->
<#--}-->

<#--.aCss {-->
	<#--overflow: hidden;-->
	<#--word-break: keep-all;-->
	<#--white-space: nowrap;-->
	<#--text-overflow: ellipsis;-->
	<#--text-align: left;-->
	<#--font-size: 12px;-->
<#--}-->

<#--.liCss {-->
	<#--white-space: nowrap;-->
	<#--text-overflow: ellipsis;-->
	<#--overflow: hidden;-->
	<#--height: 30px;-->
	<#--text-align: left;-->
	<#--margin-left: 10px;-->
	<#--margin-right: 10px;-->
<#--}-->
<#--</style>-->
	<#--<form action="${basepath}/manage/keyvalue" method="post">-->
				<#--<table class="table table-bordered">-->
					<#--<tr>-->
						<#--<td style="text-align: right;">键</td>-->
						<#--<td style="text-align: left;">-->
							<#--<input type="text" name="key1" id="e.key1" value="${e.key1!""}">-->
						<#--</td>-->
						<#--<td style="text-align: right;">值</td>-->
						<#--<td style="text-align: left;">-->
                            <#--<input type="text" name="value" id="e.value" value="${e.value!""}">-->
						<#--</td>-->
					<#--</tr>-->
					<#--<tr>-->
						<#--<td colspan="6">-->
							<#--<button method="selectList" class="btn btn-primary" onclick="selectList(this)">-->
								<#--<i class="icon-search icon-white"></i> 查询-->
							<#--</button>-->
							<#--<a href="${basepath}/manage/keyvalue/toAdd" class="btn btn-success">-->
								<#--<i class="icon-plus-sign icon-white"></i> 添加-->
                            <#--</a>-->
							<#--<button method="deletes" class="btn btn-danger" onclick="return submitIDs(this,'确定删除选择的记录?');">-->
								<#--<i class="icon-remove-sign icon-white"></i> 删除-->
							<#--</button>-->
							<#---->
							<#--<div style="float: right;vertical-align: middle;bottom: 0px;top: 10px;">-->
								<#--<#include "/manage/system/pager.ftl"/>-->
							<#--</div>-->
						<#--</td>-->
					<#--</tr>-->
				<#--</table>-->
				<#---->
				<#--<table class="table table-bordered table-hover">-->
					<#--<tr style="background-color: #dff0d8">-->
						<#--<th width="20"><input type="checkbox" id="firstCheckbox" /></th>-->
						<#--<th style="display: none;">编号</th>-->
						<#--<th >键</th>-->
						<#--<th >值</th>-->
						<#--<th >操作</th>-->
					<#--</tr>-->
					<#--<#list pager.list as item>-->
						<#--<tr>-->
							<#--<td><input type="checkbox" name="ids"-->
								<#--value="${item.id}" /></td>-->
							<#--<td style="display: none;">&nbsp;${item.id}</td>-->
							<#--<td>&nbsp;${item.key1!""}</td>-->
							<#--<td>&nbsp;${item.value!""}</td>-->
							<#--<td><a href="toEdit?id=${item.id}">编辑</a></td>-->
						<#--</tr>-->
					<#--</#list>-->
					<#--<tr>-->
						<#--<td colspan="17" style="text-align: center;">-->
							<#--<#include "/manage/system/pager.ftl"/></td>-->
					<#--</tr>-->
				<#--</table>-->

	<#--</form>-->


<form id="searchForm" class="form-panel">
    <ul class="panel-content">
        <li>
        <div class="control-group span8">
            <label class="control-label">键：</label>
            <div class="controls">
                <input type="text" name="key1" id="key1" value="${e.key1!""}">
			</div>
        </div>
        <div class="control-group span8">
            <label class="control-label">值：</label>
            <div class="controls">
                <input type="text" name="value" id="value" value="${e.value!""}">
            </div>
        </div>
        <div class="form-actions span8">
            <button   type="submit" class="button button-primary"  >
                <i class="icon-search icon-white"></i> 查询
            </button>
            <a href="${basepath}/manage/keyvalue/toAdd" class="button button-success"><i class="icon-plus-sign icon-white"></i> 添加</a>
            <button  class="button button-primary"  onclick="return delFunction()">
                <i class="icon-remove-sign icon-white"></i>删除
            </button>
        </div>
    </li>
        </ul>
</form>
<div id="grid"></div>

<script>
    var Grid = BUI.Grid,
            Store = BUI.Data.Store,
            columns = [
                {title : '编号',dataIndex :'id', width:100},
                {title : '键',dataIndex :'key1', width:300},
                {title : '值',dataIndex : 'value',width:200},
                {title : '操作',dataIndex : 'id',width:200,renderer : function (value) {
                        return '<a href="${basepath}/manage/keyvalue/toEdit?id=' + value + '">编辑</a>';
                }}
            ];

    var store = new Store({
                url : 'loadData',
                autoLoad:true, //自动加载数据
                params : { //配置初始请求的参数
                    length : '10',
                    key1:$("#key1").val(),
                    value:$("#value").val()
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

    //删除选中的记录
    function delFunction(){
        var selections = grid.getSelection();
        var ids=new Array();
        for(var i=0;i<selections.length;i++){
            ids[i]=selections[i].id.toString()
        }
        $.ajax({
            type: "POST",
            url: "${basepath}/manage/keyvalue/deletesJson",
            dataType: "json",
            data: {
                ids:ids
            },
            success: function (data) {
                var obj = form.serializeToObject();
                obj.start = 0; //返回第一页
                store.load(obj);
            }
        });

    }

</script>

</@page.pageBase>