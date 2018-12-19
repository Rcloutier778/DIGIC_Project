import os

cdir=os.getcwd()


### Schematic file
with open("schm_DOFILE","w+") as f:
    f.write('''$import_verilog("'''+cdir+'''/mlp_model.v", "'''+cdir+'''", "$ADK/technology/adk_map.vmp", @noreplace, @notemplate, @nokeep, "", @noreplace)
    $$close_session(void)
    ''')


### Viewpoint file

with open("viewpoint_DOFILE", "w+") as f:
    f.write('''$$open_design_viewpoint("'''+cdir+'''/mlp_model", "default", "", @interface, @editable, void, @current);
$set_active_window("Design_Viewpoint");
$set_active_window("Design_Configuration");
$save_design_viewpoint("'''+cdir+'''/viewpoint", @nolock, @nocleanup);
$$close_design_viewpoint();
$set_active_window("Design_Viewpoint");
$set_active_window("session");
$set_active_window("Design_Configuration");
$set_active_window("session");
$replace_palette("Setup");
$update_palette();
$$close_session(void);
''')



### Layout file

#Save
saveFile='''
$save_cell(@context);
$reserve_cell(@nohierarchy);
'''

fileContents=''


init='''
$change_workspace("Tabbed");
   ic_session@@$ic_attach_library = "$ADK/technology/ic/process/tsmc018";
   ic_session@@$ic_angle_mode = @ninety;
   ic_session@@$ic_cell_type = @block;
   ic_session@@$ic_site_type = [];
   $set_create_cell_devices(@off);
   $load_process("$ADK/technology/ic/process/tsmc018");
   $load_rules("$ADK/technology/ic/process/tsmc018.rules");
   $create_cell("'''+cdir+'''/layout", @block, @correct_by_construction, @ninety, "$ADK/technology/ic/process/tsmc018", "$ADK/technology/ic/process/tsmc018", "", @eddm, [], @full_hierarchy, @nocreate_prim, ["group_name"], [], "'''+cdir+'''", @false, []);
$set_active_window("IC 0");
   $load_logic_from_eddm("'''+cdir+'''/viewpoint", @full_hierarchy, @nocreate_prim, ["group_name"], [], "'''+cdir+'''", @false, [], @replace, "", "", @false, @false, "'''+cdir+'''");
   extern ic_session@@$ic_sdl_layout_window = "IC 0";
   $close_logic();
   $open_logic();
   $setup_icon_font("ALL", "ic_tool_icon");
   $setup_icon("Schematic_view", "v");

$open_logic();
'''
fileContents+=init


#SDL_AUTO in schematic 
sheetfiles=os.listdir(cdir+'/mlp_model/schematic')
sheetfiles = [e for e in sheetfiles if 'mgc_sheet.attr' in e]
maxsheet=len(sheetfiles)
corr = raw_input("Is "+str(maxsheet)+" sheets correct? [y/n]")
if corr.lower() =='n':
    with open('DOFILE','w+') as f:
        f.write('$exit')
    1/0

sdl_auto=''
for i in range(1, maxsheet+1):
    sdl_auto+='''
$$open_sheet(["/ : sheet'''+str(i)+'''"], @noentity, @pop_existing)
$sdl_auto(void, void, @automatic, void, @use_default)
'''
    sdl_auto+=saveFile

fileContents+=sdl_auto

fileContents+=saveFile



#Autofp
fileContents+='''
$autofloorplan(0.5, 1.5, 0, 3000, 3000, 0.0, 0.0, 0.0, 0.0, 1.0, 0, @auto, @auto, 0, [@normal, @mirror_x], 0, [@mirror_y, @mirror_xy], 0, [@rotate_ccw, @rotate_mirror_y], 0, [@rotate_mirror_x, @rotate_mirror_xy], @auto, @nokeep, @normal, "");
'''

fileContents+=saveFile

#StdCells
fileContents+='''
$select_all(void);
$autoplace_standard_cells([[0, 0], [0, 0]], @rand_n_improve, @bal, 0, 0.0, @true);
'''

fileContents+=saveFile

#Ports
fileContents+='''
$select_all(void);
$autoplace_ports(@local, [@left, @right, @bottom, @top], void, 0.0, @selected_order, void, "", "M5", "M4");
$view_all();
'''

fileContents+=saveFile

#Route options
fileContents+='''
$set_route_max_pops(10000);
'''

#Route
fileContents+='''
$select_all(void);
$aroute();
'''
fileContents+=saveFile

#Compact
fileContents+='''
$select_all(void);
$compact(@down, @extent, [[0, 0], [0, 0]], @no, @fixed, @unrestricted, @clear_corners, @pins_and_blockages, @no, @fixed, @reduce_tromboning, [5, 4, 3, 2, 1], [1, 1, 1, 1, 1], @true, @false, @false, @nokeep, @false, @euclidean, @reports, 0, @no_violations_only, @true);
'''
fileContents+=saveFile


with open("DOFILE","w+") as f:
    f.write(fileContents)

