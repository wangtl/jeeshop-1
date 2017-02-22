<#import "/manage/tpl/pageBase.ftl" as page>
<@page.pageBase currentMenu="用户管理">
<form id="searchForm" class="form-panel" tabindex="0" style="outline: none;">
    <ul class="panel-content">
        <li>
            <div class="control-group span8">
                <label class="control-label">状态：</label>
                <div class="controls">
                    <select name="status" class="input-normal" id="status">
                        <option value="">全部</option>
                        <option value="y">启用</option>
                        <option value="n">禁用</option>
                    </select>
                </div>
            </div>
            <div class="form-actions span8">
                <#if checkPrivilege("/manage/user/search") >
                    <button   type="submit" class="button  button-primary"  >
                        查询
                    </button>
                </#if>
                <#if checkPrivilege("/manage/user/insert") >
                    <a href="${basepath}/manage/user/toAdd" class="button button-success">添加</a>
                </#if>
                <button  class="button button-danger"  onclick="return delFunction()">
                  删除
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
                {title : '帐号',dataIndex :'username', width:100},
                {title : '昵称',dataIndex :'nickname', width:100},
                {title : '创建时间',dataIndex : 'createtime',width:100},
                {title : '角色',dataIndex : 'role_name',width:100},
                {title : '状态',dataIndex : 'status',width:100, renderer:function(data){
					if(data == "y"){
						return '<img src="${basepath}/resource/images/action_check.gif">';
					} else {
						return '<img src="${basepath}/resource/images/action_delete.gif">';
					}
				}},
                {title : '操作',dataIndex : 'id',width:200,renderer : function (value) {

					<#if checkPrivilege("/manage/user/edit")>
                        return '<a href="${basepath}/manage/user/toEdit?id=' + value + '">编辑</a>';
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
            url: "${basepath}/manage/user/deletesJson",
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