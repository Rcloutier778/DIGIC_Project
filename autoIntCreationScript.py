init="""
$change_workspace("Tabbed");
   ic_session@@$ic_attach_library = "$ADK/technology/ic/process/tsmc018";
   ic_session@@$ic_angle_mode = @ninety;
   ic_session@@$ic_cell_type = @block;
   ic_session@@$ic_site_type = [];
   $set_create_cell_devices(@off);
   $load_process("$ADK/technology/ic/process/tsmc018");
   $load_rules("$ADK/technology/ic/process/tsmc018.rules");
   $create_cell("/home/rxc1028/digicdesign/project/layout", @block, @correct_by_construction, @ninety, "$ADK/technology/ic/process/tsmc018", "$ADK/technology/ic/process/tsmc018", "", @eddm, [], @full_hierarchy, @nocreate_prim, ["group_name"], [], "/home/rxc1028/digicdesign/project", @false, []);
$set_active_window("IC 0");
   $load_logic_from_eddm("/home/rxc1028/digicdesign/project/viewpoint", @full_hierarchy, @nocreate_prim, ["group_name"], [], "/home/rxc1028/digicdesign/project", @false, [], @replace, "", "", @false, @false, "/home/rxc1028/digicdesign/project");
   extern ic_session@@$ic_sdl_layout_window = "IC 0";
   $close_logic();
   $open_logic();
   $setup_icon_font("ALL", "ic_tool_icon");
   $setup_icon("Schematic_view", "v");

$open_logic();
"""
maxsheet=1000
for i in range(1, maxsheet):
    init+='''
$$open_sheet(["/ : sheet'''+str(i)+'''"], @noentity, @pop_existing)
$sdl_auto(void, void, @automatic, void, @use_default)
'''

init+='''
$autofloorplan(0.5, 1.5, 0, 3000, 3000, 0.0, 0.0, 0.0, 0.0, 1.0, 0, @auto, @auto, 0, [@normal, @mirror_x], 0, [@mirror_y, @mirror_xy], 0, [@rotate_ccw, @rotate_mirror_y], 0, [@rotate_mirror_x, @rotate_mirror_xy], @auto, @nokeep, @normal, "");
'''

init+='''
$select_all(void);
   $autoplace_standard_cells([[0, 0], [0, 0]], @init_n_improve, @bal, 0, 0.0, @false);
'''

init+='''
$select_all(void);
$autoplace_ports(@local, [@left, @right, @bottom, @top], void, 0.0, @selected_order, void, "", "M5", "M4");
//  Note: Total time in $autoplace_ports():   CPU Seconds = 0   Wall Clock Seconds = 0 (from: Ic/apr/auto-tools 87)
   $view_all();
'''



init+='''
$save_cell(@context);
$reserve_cell(@nohierarchy);
'''

init+='''
$save_cell(@context);
'''
init+='''
$set_route_max_pops(10000);
'''

init+='''
$select_all(void);
$aroute();
$select_all(void);
$compact(@down, @extent, [[0, 0], [0, 0]], @no, @fixed, @unrestricted, @clear_corners, @pins_and_blockages, @no, @fixed, @reduce_tromboning, [5, 4, 3, 2, 1], [1, 1, 1, 1, 1], @true, @false, @false, @nokeep, @false, @euclidean, @reports, 0, @no_violatio\
ns_only, @true);
$save_cell(@context);
'''


with open("autoInstDOFILE","w+") as f:
    f.write(init)

