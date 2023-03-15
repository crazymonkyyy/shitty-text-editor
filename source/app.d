import raylib;
import basic;
import monkyyykeys;
enum textsize=24;
enum linespaceing=2;
void main(string[] s_){
	SetConfigFlags(ConfigFlags.FLAG_WINDOW_RESIZABLE);
	GetMonitorWidth(GetCurrentMonitor).writeln;
	InitWindow(0,0, "shitty text editor");
	SetWindowSize(GetMonitorWidth(GetCurrentMonitor)*3/4, 
			GetMonitorHeight(GetCurrentMonitor)*3/4);
	SetWindowPosition(GetMonitorWidth(GetCurrentMonitor)/8,
			GetMonitorHeight(GetCurrentMonitor)/8);
	//--- reasonable tool gui initualization
	SetTargetFPS(60);
	string[] text;//main data
	int line,chr;//postion in document
	int selectedtop,selectedbot;// copy and paste selection
	string message;//status message
	int statusstickyness;//count down hack
	
	void selectline(){
		//if(IsKeyPressed(KeyboardKey.KEY_LEFT_SHIFT)){
		if(button.shift){//.down acts strangely?
			//if(! button.shift.down){
			//	"IM WIERD".writeln;
			//}
			selectedtop=min(selectedtop,line);
			selectedbot=max(selectedbot,line);
			message=selectedtop.to!string~":"~selectedbot.to!string;
			statusstickyness=300;
		} else {
			//if(button.shift.down){
			//	"EXTERMELY".writeln;
			//}
			selectedtop=line;
			selectedbot=line;
		}
	}
	void save(){
		auto o=File(s_[1],"w");
		foreach(s;text){
			o.writeln(s);
		}
		message="File saved";
		statusstickyness=300;
	}
	//---
	foreach(s;File(s_[1]).byLine){
		text~=s.dup;//load in text
	}
	if(text.length==0){
		text~="";
	}
	//save;
	while (!WindowShouldClose()){
		BeginDrawing();
			ClearBackground(Colors.BLACK);
			//----
			int y=GetScreenHeight/2-(textsize/2);//drawing location
			if(MeasureText(text[line].toStringz,textsize)<GetScreenWidth){
				DrawText(text[line].toStringz,0,y,textsize,Colors.WHITE);
				int x=MeasureText(text[line][0..chr].toStringz,textsize);
				DrawRectangle(x,y,3,textsize,Colors.GRAY);
			} else {
				//sadness path
			}
			foreach(i;line+1..text.length){//draw lines under selection
				y+=textsize+linespaceing;
				DrawText(text[i].toStringz,0,y,textsize,Colors.WHITE);
			}
			y=GetScreenHeight/2-(textsize/2);
			foreach_reverse(i;0..line){//draw lines above
				y-=textsize+linespaceing;
				DrawText(text[i].toStringz,0,y,textsize,Colors.WHITE);
			}
			
			if(statusstickyness>0){
				DrawRectangle(0,0,
					MeasureText(message.toStringz,textsize),textsize,Colors.WHITE);
				DrawText(message.toStringz,0,0,textsize,Colors.BLACK);
				statusstickyness--;
			}
			
			//--- logical input handling
			with(button){
			if(down.held||down.pressed){
				line++;
				line=min(line,text.length-1);
				chr=0;
				selectline;
			}
			if (up.held || up.pressed) {
				line--;
				line=max(line,0);
				chr=0;
				selectline;
			}
			if(right.held||right.pressed){
				chr++;
				chr=min(chr,(cast(int)text[line].length));
			}
			if (left.held || left.pressed) {
				chr--;
				chr = max(chr, 0);
			}
			if(ctrl+s){
				save;
			}
			if(ctrl+c){
				text[selectedtop..selectedtop+1]
					.join('\n')
					.toStringz
					.SetClipboardText;
				message="copied";
				statusstickyness=30;
			}
			if(ctrl+v){
				string temp=GetClipboardText.to!string;
				string[] temp2=temp.splitter('\n').array;
				text=text[0..line]~temp2~text[line..$];
			}
			}
			//--- typing input handling
			int key=GetCharPressed;
			if(key<127&&key>0){
				text[line]=text[line][0..chr]~key.to!char~text[line][chr..$];
				chr++;
			}
			with(button){
			if(enter.pressed){
				text=text[0..line]~""~text[line..$];
				line++;
			}
			if(backspace.pressed){
				if(chr==0){//backspacing the start of the line should remove a implied endline
					if(line==0){}
					else{
					chr=cast(int)text[line-1].length;//doing this first so it knows the length
					text[line-1]~=text[line];
					text=text[0..line]~text[line+1..$];
					line--;
				}} else {
					text[line]=text[line][0..chr-1]~text[line][chr..$];
					chr--;
				}
			}
			}
		EndDrawing();
	}
	CloseWindow();
}