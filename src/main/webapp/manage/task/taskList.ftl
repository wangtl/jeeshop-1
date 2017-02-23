<#import "/manage/tpl/pageTep.ftl" as page>
<@page.pageBase currentMenu="任务管理">
<form id="searchForm" class="form-panel">
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
                {title : '任务代号',dataIndex :'code', width:100},
                {title : '任务名称',dataIndex :'name', width:100},
                {title : '睡眠时间',dataIndex : 'sleep',width:100},
                {title : '睡眠单位',dataIndex : 'unit',width:100},
                {title : '下次执行任务的时间',dataIndex : 'nextWorkTime',width:100},
                {title : '当前状态',dataIndex : 'currentStatus',width:100},
                {title : '操作',dataIndex : 'id',width:200,renderer : function (value,obj.index) {
                        if(obj.currentStatus=="run"){
                            return '<a href="javascript:stopTask()">立即终止</a>';
                        }else{
                            return '<a href="javascript:startTask()">立即执行</a>';
                        }
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

    function startTask(){
        $.ajax({
            url:'${basepath}/manage/task/startTask',
            type:'GET', //GET
            dataType:'json',    
            success:function(data,textStatus,jqXHR){
                BUI.Message.Alert('启动任务成功！','success');
            }
        })
    }

     function stopTask(){
            $.ajax({
            url:'${basepath}/manage/task/stopTask',
            type:'GET', //GET
            dataType:'json',    //返回的数据格式：json/xml/html/script/jsonp/text
            success:function(data,textStatus,jqXHR){
                BUI.Message.Alert('停止任务成功！','success');
            }
        })
    }

</script>

</@page.pageBase>