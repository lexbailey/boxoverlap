unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, Spin,
  StdCtrls, ExtCtrls, Math;

type


  TLogicBox = record
    //This class represents one decision logic diagram box.
    //Where this is used in the code, you will have to change things
    //so that they make use of whatever objects you have to represent
    //these boxes instead of this one.
    x, y, width, height: integer;
  end;


  { TForm1 }

  TForm1 = class(TForm)
    btnReDraw: TButton;
    btnAlign: TButton;
    seMinRatio: TFloatSpinEdit;
    Label1: TLabel;
    Label2: TLabel;
    memRes: TMemo;
    Panel1: TPanel;
    sbLogic: TScrollBox;
    seNumItems1: TSpinEdit;
    procedure btnAlignClick(Sender: TObject);
    procedure btnReDrawClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PanelMouseLeave(Sender: TObject);
    procedure PanelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer
      );
    procedure PanelMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PanelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  LogicBoxData: array of TLogicBox;
  LogicBoxes: array of TPanel;
  DragPanel: integer;

const PADDING: integer = 5;

implementation

{$R *.lfm}

{ TForm1 }

procedure TForm1.btnReDrawClick(Sender: TObject);
var num, i: integer;
begin

  //This function just prepares a new amount of boxes and draws them on the screen
  for i := 0 to length(LogicBoxes)-1 do begin
    if (assigned(LogicBoxes[i])) then
        LogicBoxes[i].free;
  end;

  num := seNumItems1.Value;
  setlength(LogicBoxData, num);
  setlength(LogicBoxes, num);
  for i := 0 to num-1 do begin
    LogicBoxData[i].x:=20*(i+1);
    LogicBoxData[i].y:=20*(i+1);
    LogicBoxData[i].width:=(80);
    LogicBoxData[i].height:=40;
    LogicBoxes[i] := TPanel.create(form1);
    LogicBoxes[i].Parent := sbLogic;
    LogicBoxes[i].Top := LogicBoxData[i].y;
    LogicBoxes[i].Left := LogicBoxData[i].x;
    LogicBoxes[i].Width := LogicBoxData[i].width;
    LogicBoxes[i].Height := LogicBoxData[i].height;
    LogicBoxes[i].Color:=clBlue;
    LogicBoxes[i].Tag:=i;
    LogicBoxes[i].Caption:=inttostr(i);
    LogicBoxes[i].OnMouseDown:=@PanelMouseDown;
    LogicBoxes[i].OnMouseUp:=@PanelMouseUp;
    LogicBoxes[i].OnMouseMove:=@PanelMouseMove;
    LogicBoxes[i].OnMouseLeave:=@PanelMouseLeave;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  //Not dragging any panels at start
  DragPanel := -1;
end;

procedure TForm1.PanelMouseLeave(Sender: TObject);
begin
  //Handle dragging
  if DragPanel >= 0 then begin
    LogicBoxes[DragPanel].Top:=sbLogic.ScreenToClient(Mouse.CursorPos).Y;
    LogicBoxes[DragPanel].Left:=sbLogic.ScreenToClient(Mouse.CursorPos).X;
    LogicBoxData[DragPanel].Y:=LogicBoxes[DragPanel].Top;
    LogicBoxData[DragPanel].X:=LogicBoxes[DragPanel].Left;
  end;
end;

procedure TForm1.PanelMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  //Handle dragging
  if DragPanel >= 0 then begin
    LogicBoxes[DragPanel].Top:=sbLogic.ScreenToClient(Mouse.CursorPos).Y;
    LogicBoxes[DragPanel].Left:=sbLogic.ScreenToClient(Mouse.CursorPos).X;
    LogicBoxData[DragPanel].Y:=LogicBoxes[DragPanel].Top;
    LogicBoxData[DragPanel].X:=LogicBoxes[DragPanel].Left;
  end;
end;

procedure TForm1.PanelMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  //Mouse released, no more drag
  DragPanel := -1;
end;

procedure TForm1.PanelMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  //Start drag
  DragPanel := TPanel(Sender).Tag;
end;

//Determine if there is a horizontal overlap between two boxes given their
//indexes in the list
function doOverlapH(i,j:integer):boolean;
var box1X, box1W: integer;
    box2X, box2W: integer;
begin
  //This function must be re-implemented for the REAL location storage method
  //The first four lines must change
  box1X := LogicBoxData[i].x;
  box1W := LogicBoxData[i].width;

  box2X := LogicBoxData[j].x;
  box2W := LogicBoxData[j].width;

  result :=
  ((box1X >= box2X) and (box1X < box2X + box2W))
  or
  ((box2X >= box1X) and (box2X < box1X + box1W))
end;

//Determine if there is a vertical overlap between two boxes given their
//indexes in the list
function doOverlapV(i,j:integer):boolean;
var box1Y, box1H: integer;
    box2Y, box2H: integer;
begin
  //This function must be re-implemented for the REAL location storage method
  //The first four lines must change
  box1Y := LogicBoxData[i].y;
  box1H := LogicBoxData[i].height;

  box2Y := LogicBoxData[j].y;
  box2H := LogicBoxData[j].height;

  result :=
  ((box1Y >= box2Y) and (box1Y < box2Y + box2H))
  or
  ((box2Y >= box1Y) and (box2Y < box1Y + box1H))
end;

//Determine if there is an overlap between two boxes given their
//indexes in the list
function doOverlap(i,j:integer):boolean;
begin
  result := (doOverlapH(i,j) and doOverlapV(i,j));
end;

//Determine the distance of a horizontal overlap, returns 0 if no overlap
function overlapDistanceH(i,j: integer): integer;
var box1X, box1W: integer;
    box2X, box2W: integer;
    dif1, dif2: integer;
begin
  //This function must be re-implemented for the REAL location storage method
  //The first four lines must change


  if doOverlapH(i,j) then begin
    box1X := LogicBoxData[i].x;
    box1W := LogicBoxData[i].width;

    box2X := LogicBoxData[j].x;
    box2W := LogicBoxData[j].width;

    dif1:= box1X+box1W - box2X;
    dif2:= box2X+box2W - box1X;

    result := min(min(dif1, dif2), min(box1W, box2W));
  end else
  begin
    result := 0;
  end;
end;

//Determine the distance of a vertical overlap, returns 0 if no overlap
function overlapDistanceV(i,j: integer): integer;
var box1Y, box1H: integer;
    box2Y, box2H: integer;
    dif1, dif2: integer;
begin
  //This function must be re-implemented for the REAL location storage method
  //The first four lines must change


  if doOverlapV(i,j) then begin
    box1Y := LogicBoxData[i].y;
    box1H := LogicBoxData[i].height;

    box2Y := LogicBoxData[j].y;
    box2H := LogicBoxData[j].height;

    dif1:= box1Y+box1H - box2Y;
    dif2:= box2Y+box2H - box1Y;

    result := min(min(dif1, dif2), min(box1H, box2H));
  end else
  begin
    result := 0;
  end;
end;

//Select a box that will keep still for a vertical movement.
//This function takes two indexes and returns the index of the box that has a y
//value higher than the other.
function selectBoxV(i,j:integer):integer;
var box1Y, box2Y: integer;
begin
  box1Y := LogicBoxData[i].y;
  box2Y := LogicBoxData[j].y;
  result := j;
  if box1Y < box2Y then
    result := i;
end;

//Select a box that will keep still for a horizontal movement.
//This function takes two indexes and returns the index of the box that has an x
//value higher than the other.
function selectBoxH(i,j:integer):integer;
var box1X, box2X: integer;
begin
  box1X := LogicBoxData[i].x;
  box2X := LogicBoxData[j].x;
  result := j;
  if box1X < box2X then
    result := i;
end;

//This is the function that aligns the boxes. (should probably be moved out of
//an event handler)
procedure TForm1.btnAlignClick(Sender: TObject);
var i, j, k: integer;
    overV, overH: integer;
    ratio: double;
    toKeep: integer;
begin
  //Set all box colours to blue
  for i := 0 to length(LogicBoxData)-1 do begin
      LogicBoxes[i].Color:=clBlue;
  end;
  //Clear log
  memRes.Clear;
  //For each box, matched with each other box...
  for i := 0 to length(LogicBoxData)-1 do begin
    for j := i+1 to length(LogicBoxData)-1 do begin
        //Check for overlap between boxes i and j
        if doOverlap(i,j) then
        begin
          memRes.Append('Overlap: ' + inttostr(i) + ', ' + inttostr(j));
          //Get overlap distances
          overV := overlapDistanceV(i,j);
          overH := overlapDistanceH(i,j);
          memRes.Append('  H: ' + inttostr(overH) + ', V: ' + inttostr(overV));
          //Calculate the ratio between horizontal and vertical overlap
          ratio := overH/overV;
          memRes.Append('  Ratio: ' + floattostr(ratio));
          if ratio > seMinRatio.Value then begin
            //If ratio allows, do a vertical shift
            toKeep := selectBoxV(i,j);
            memRes.Append('  Move away from ' + inttostr(toKeep) + ' Vertical');
            for k := 0 to length(LogicBoxData)-1 do begin
              //Move any box that is not the one to keep still and is further
              //from the top than the one to keep still (shift all away)
              if (k <> toKeep) and (LogicBoxData[k].y >= LogicBoxData[toKeep].y) then begin
                LogicBoxData[k].y:=LogicBoxData[k].y + overV + PADDING;
                LogicBoxes[k].Top := LogicBoxData[k].y;
              end;
            end;
          end else
          begin
            //If ratio allows, do a horizontal shift
            toKeep := selectBoxH(i,j);
            memRes.Append('  Move away from ' + inttostr(toKeep) + ' Horizontal');
            for k := 0 to length(LogicBoxData)-1 do begin
              //Move any box that is not the one to keep still and is further
              //from the left than the one to keep still (shift all away)
              if (k <> toKeep) and (LogicBoxData[k].x >= LogicBoxData[toKeep].x) then begin
                LogicBoxData[k].x:=LogicBoxData[k].x + overH + PADDING;
                LogicBoxes[k].Left := LogicBoxData[k].x;
              end;
            end;
          end;
          //Colour boxes that were colliding, to show where conflicts were
          //resolved
          LogicBoxes[i].Color:=clRed;
          LogicBoxes[j].Color:=clRed;
        end;
    end;
  end;
end;

end.

