<#macro menu menus=[] topMenu="" currentMenu="首页">

<!-- /.navbar-top-links -->
<ul  id="side-menu">
</ul>
<!-- /.sidebar-collapse -->
<!-- /.navbar-static-side -->
<script type="text/javascript">

    var Menu = BUI.Menu;
    var data =[
        <#list menus as menu>
            {
                text: '${menu.name}',
                <#if menu.children?? && menu.children?size gt 0>
                    items: [
                        <#list menu.children as menu>
                            {
                                text: '${menu.name}',
                                href: '${basepath}${menu.url}',
                                <#if menu.name==currentMenu>
                                    selected:true
                                </#if>
                            },
                        </#list>
                    ],
                <#else>
                    href:'${basepath}${menu.url}',
                    selected:true
                </#if>
            },
        </#list>
    ];



    var sideMenu = new Menu.SideMenu({
        render:'#side-menu',
        width:150,
        items :data
    });

    sideMenu.render();
    sideMenu.on('menuclick', function(e){
        window.location.href=e.item.get('href');
        console.log(e.item.get('href'));
    });

</script>

</#macro>