<#import "/manage/tpl/pageTep.ftl" as page>
<@page.pageBase currentMenu="角色管理">
<form id="searchForm" class="form-panel">
    <ul class="panel-content">
        <li>
        <div class="form-actions">
			<#if checkPrivilege("role/insert")>
                <a href="${basepath}/manage/role/toAdd" class="button button-success"><i class="icon-plus-sign icon-white"></i> 添加</a>
			</#if>
        </div>
        </li>
    </ul>
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