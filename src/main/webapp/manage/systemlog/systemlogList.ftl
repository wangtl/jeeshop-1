<#import "/manage/tpl/pageBase.ftl" as page>
<@page.pageBase currentMenu="日志管理">
<#--<script>-->
<#--$(function(){-->
    <#--var table = $('#dataTable').DataTable({-->
        <#--"ajax": {-->
            <#--url:"loadData",-->
            <#--dataSrc:"list"-->
        <#--},-->
        <#--columns:[-->
            <#--{name:"title", title:"标题", data:"title"},-->
            <#--{name:"account", title:"账号", data:"account"},-->
            <#--{name:"logintime", title:"登陆时间", data:"logintime"},-->
            <#--{name:"loginIP", title:"登陆IP", data:"loginIP"},-->
                <#--{name:"loginArea", title:"登陆位置", data:"loginArea"},-->
            <#--{name:"diffAreaLogin", title:"是否异地登录", data:"diffAreaLogin",render:function(data,type,row,meta){-->
				<#--return data=="y"?"是":"否";-->
            <#--}}-->
        <#--]-->
    <#--});-->
<#--});-->
<#--</script>-->
	<#--<form action="${basepath}/manage/systemlog" method="post" theme="simple">-->
				<#--<table class="table table-bordered">-->
					<#--<tr>-->
						<#--<td style="text-align: right;">是否异登陆</td>-->
						<#--<td style="text-align: left;">-->
							<#--<#assign y_n = {'':"全部",'y':'是','n':'否'}>-->
                            <#--<select id="diffAreaLogin" name="diffAreaLogin">-->
							<#--<#list y_n?keys as key>-->
                                <#--<option value="${key}" <#if e.diffAreaLogin?? && e.diffAreaLogin==key>selected="selected" </#if>>${y_n[key]}</option>-->
							<#--</#list>-->
                            <#--</select>-->
						<#--</td>-->
						<#--<td>登陆账号</td>-->
						<#--<td><input type="text" value="${e.account!""}" class="input-medium search-query" name="account"/></td>-->
					<#--</tr>-->
				<#--</table>-->

				<#--<table class="table table-bordered">-->
					<#--<tr>-->
						<#--<td colspan="16">-->
							<#--<button method="selectList" class="btn btn-primary" table-id="dataTable" onclick="return selectList(this)">-->
								<#--<i class="icon-search icon-white"></i> 查询-->
							<#--</button>-->
						<#--</td>-->
					<#--</tr>-->
				<#--</table>-->

        <#--<table class="display stripe row-border cell-border" id="dataTable">-->
        <#--</table>-->
	<#--</form>-->



<form id="searchForm" class="form-horizontal" tabindex="0" style="outline: none;">
    <div class="row">
        <div class="control-group">
            <label class="control-label">是否异登陆：</label>
            <div class="controls">
				<#assign y_n = {'':"全部",'y':'是','n':'否'}>
                <select name="diffAreaLogin" class="input-normal" id="diffAreaLogin">
					<#list y_n?keys as key>
                        <option value="${key}" <#if e.diffAreaLogin?? && e.diffAreaLogin==key>selected="selected" </#if>>${y_n[key]}</option>
					</#list>
                </select>
            </div>
        </div>
        <div class="control-group">
            <label class="control-label">登陆账号：</label>
            <div class="controls">
                <input type="text" value="${e.account!""}" class="input-normal" name="account"  id="account"/>
            </div>
        </div>
    </div>
    <div class="row actions-bar">
        <div class="form-actions">
                <button   type="submit" class="btn btn-primary"  >
                    <i class="icon-search icon-white"></i> 查询
                </button>
        </div>
    </div>
</form>
<div id="grid"></div>

<script>
    var Grid = BUI.Grid,
            Store = BUI.Data.Store,
            columns = [
                {title : '标题',dataIndex :'title', width:100},
                {title : '账号',dataIndex :'account', width:100},
                {title : '登陆时间',dataIndex : 'logintime',width:100},
                {title : '登陆IP',dataIndex : 'loginIP',width:100},
                {title : '登陆位置',dataIndex : 'loginArea',width:100},
                {title : '是否异地登录',dataIndex : 'diffAreaLogin',width:100, renderer:function(data){
                    return data=="y"?"是":"否";
                }}
            ];

    var store = new Store({
                url : 'loadData',
                autoLoad:true, //自动加载数据
                params : { //配置初始请求的参数
                    length : '10',
                    diffAreaLogin:$("#diffAreaLogin").val(),
                    account:$("#account").val()
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