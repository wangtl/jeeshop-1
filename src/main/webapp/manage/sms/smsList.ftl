<#import "/manage/tpl/pageTep.ftl" as page>
<@page.pageBase currentMenu="短信管理">
<form id="searchForm" class="form-panel">
    <ul class="panel-content">
        <li>
            <div class="control-group span8">
                <label class="control-label">手机号码：</label>
                <div class="controls">
                    <input type="text" name="phone" id="phone" value="">
                </div>
            </div>
            <div class="form-actions span8">
                <button   type="submit" class="button  button-primary"  >
                    查询
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
                {title : '手机号码',dataIndex :'phone', width:100},
                {title : '短息内容',dataIndex :'content', width:100},
                {title : '发送时间',dataIndex : 'sendTime',width:100},
                {title : '类型',dataIndex : 'type',width:100},
                {title : '发送状态',dataIndex : 'returnCode',width:100, renderer:function(data){
                    if(data == "y"){
                        return '<img src="${basepath}/resource/images/action_check.gif">';
                    } else {
                        return '<img src="${basepath}/resource/images/action_delete.gif">';
                    }
                }},
                {title : '操作',dataIndex : 'id',width:200,renderer : function (value) {
                        return '<a href="${basepath}/manage/sems/updateSendSMS?id=' + value + '">重发</a>';

                }}
            ];

    var store = new Store({
                url : 'loadData',
                autoLoad:true, //自动加载数据
                params : { //配置初始请求的参数
                    length : '10',
                    status:$("#phone").val()
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


</script>

</@page.pageBase>