<#import "/manage/tpl/pageTep.ftl" as page>
<@page.pageBase currentMenu="缓存更新">
<div class="form-panel">
    <ul class="panel-content">
        <li>
            <div class="control-group span2">
                <label class="control-label">状态：</label>
            </div>
            <div class="control-group span6">
                <div class="controls">
                    <select name="status" class="input-normal" id="status">
                        <option value="loadAllCache">后台缓存</option>
                        <option value="frontCache">前台缓存</option>
                        <option value="frontCache?method=activity">加载活动+活动商品列表</option>
                        <option value="frontCache?method=loadIndexImgs">门户滚动图片</option>
                        <option value="frontCache?method=loadAdvertList">广告列表</option>
                        <option value="frontCache?method=loadNotifyTemplate">加载邮件模板列表</option>
                        <option value="frontCache?method=loadProductStock">加载商品内存库存</option>
                        <option value="frontCache?method=hotquery">热门查询关键字</option>
                    </select>
                </div>
            </div>
            <div class="form-actions span8">
                <button  class="button  button-primary"  onclick="return loadCache()" >
                    立即更新
                </button>
            </div>
        </li>

    </ul>
</div>
<script>
    function loadCache(){
        $.ajax({
            url:'${basepath}/manage/cache/'+$("#status").val(),
            type:'GET', //GET
            dataType:'json',    //返回的数据格式：json/xml/html/script/jsonp/text
            success:function(data,textStatus,jqXHR){
                BUI.Message.Alert('更新成功！','success');
            }
        })
    }
</script>
</@page.pageBase>