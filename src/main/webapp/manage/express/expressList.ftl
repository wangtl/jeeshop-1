<#import "/manage/tpl/pageTep.ftl" as page>
<@page.pageBase currentMenu="配送方式">

<form id="searchForm" class="form-panel">
    <ul class="panel-content">
        <li>
        <div class="form-actions">

            <a href="${basepath}/manage/express/toAdd" class="button button-success">
                <i class="icon-plus-sign icon-white"></i> 添加
            </a>
		<a  class="button button-danger" onclick="return delFunction();">
			<i class="icon-remove-sign icon-white"></i> 删除
		</a>
        </div>
    </li>
    </ul>
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