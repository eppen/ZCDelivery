{*******************************************************************************
����: juner11212436@163.com 2017/11/20
����: ΢��ҵ���ͱ�ɨ���߳�
*******************************************************************************}
unit UMessageScan;

{$I Link.inc}
interface

uses
  Windows, Classes, SysUtils, DateUtils, UBusinessConst, UMgrDBConn,
  UBusinessWorker, UWaitItem, ULibFun, USysDB, UMITConst, USysLoger,
  UBusinessPacker, NativeXml, UMgrParam, UWorkerBussinessWebchat,
  UWorkerBussinessHHJY ;

type
  TMessageScan = class;
  TMessageScanThread = class(TThread)
  private
    FOwner: TMessageScan;
    //ӵ����
    FDBConn: PDBWorker;
    //���ݶ���
    FListA,FListB,FListC: TStrings;
    //�б����
    FXMLBuilder: TNativeXml;
    //XML������
    FWaiter: TWaitObject;
    //�ȴ�����
    FSyncLock: TCrossProcWaitObject;
    //ͬ������
    FNumOutFactMsg: Integer;
    //�����������Ϣ���ͼ�ʱ����
  protected
    function SendSaleMsgToWebMall(nList: TStrings):Boolean;
    //���۷�����Ϣ
    function SendOrderMsgToWebMall(nList: TStrings):Boolean;
    //�ɹ�������Ϣ
    procedure UpdateMsgNum(const nSuccess: Boolean; nLID: string);
    //������Ϣ״̬
    procedure UpdateMsgNumEx(const nSuccess: Boolean; nLID: string; nPurType: string);
    //ͬ��6��ʧ�ܵ�����ͬ��
    procedure UpdateSynFailedClear;

    procedure DoSaveOutFactMsg;
    //ִ�г�����Ϣ����
    function SaveSaleOutFactMsg(nList: TStrings):Boolean;
    //���۳�����Ϣ
    function SaveOrderOutFactMsg(nList: TStrings):Boolean;
    //���۳�����Ϣ
    procedure Execute; override;
    //ִ���߳�
  public
    constructor Create(AOwner: TMessageScan);
    destructor Destroy; override;
    //�����ͷ�
    procedure Wakeup;
    procedure StopMe;
    //��ֹ�߳�
  end;

  TMessageScan = class(TObject)
  private
    FThread: TMessageScanThread;
    //ɨ���߳�
  public
    FSyncTime:Integer;
    //�趨ͬ��������ֵ
    constructor Create;
    destructor Destroy; override;
    //�����ͷ�
    procedure Start;
    procedure Stop;
    //��ͣ�ϴ�
    procedure LoadConfig(const nFile:string);//���������ļ�
  end;

var
  gMessageScan: TMessageScan = nil;
  //ȫ��ʹ��


implementation

procedure WriteLog(const nMsg: string);
begin
  gSysLoger.AddLog(TMessageScan, '��Ӿ�Զ��Ϣɨ��', nMsg);
end;

constructor TMessageScan.Create;
begin
  FThread := nil;
end;

destructor TMessageScan.Destroy;
begin
  Stop;
  inherited;
end;

procedure TMessageScan.Start;
begin
  if not Assigned(FThread) then
    FThread := TMessageScanThread.Create(Self);
  FThread.Wakeup;
end;

procedure TMessageScan.Stop;
begin
  if Assigned(FThread) then
    FThread.StopMe;
  FThread := nil;
end;

//����nFile�����ļ�
procedure TMessageScan.LoadConfig(const nFile: string);
var nXML: TNativeXml;
    nNode, nTmp: TXmlNode;
begin
  nXML := TNativeXml.Create;
  try
    nXML.LoadFromFile(nFile);
    nNode := nXML.Root.NodeByName('Item');
    try
      FSyncTime:= StrToInt(nNode.NodeByName('SyncTime').ValueAsString);
    except
      FSyncTime:= 5;
    end;
  finally
    nXML.Free;
  end;
end;

//------------------------------------------------------------------------------
constructor TMessageScanThread.Create(AOwner: TMessageScan);
begin
  inherited Create(False);
  FreeOnTerminate := False;

  FOwner := AOwner;
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  FXMLBuilder :=TNativeXml.Create;

  FWaiter := TWaitObject.Create;
  FWaiter.Interval := 30*1000;

  FSyncLock := TCrossProcWaitObject.Create('HHJYService_MessageScan');
  //process sync
end;

destructor TMessageScanThread.Destroy;
begin
  FWaiter.Free;
  FListA.Free;
  FListB.Free;
  FListC.Free;
  FXMLBuilder.Free;

  FSyncLock.Free;
  inherited;
end;

procedure TMessageScanThread.Wakeup;
begin
  FWaiter.Wakeup;
end;

procedure TMessageScanThread.StopMe;
begin
  Terminate;
  FWaiter.Wakeup;

  WaitFor;
  Free;
end;

procedure TMessageScanThread.Execute;
var nErr, nSuccessCount, nFailCount: Integer;
    nStr: string;
    nResult : Boolean;
    nInit: Int64;
    nOut: TWorkerBusinessCommand;
begin
  FNumOutFactMsg := 0;

  while not Terminated do
  try
    FWaiter.EnterWait;
    if Terminated then Exit;

    Inc(FNumOutFactMsg);

    if FNumOutFactMsg >= 900 then
      FNumOutFactMsg := 0;

    //--------------------------------------------------------------------------
    if not FSyncLock.SyncLockEnter() then Continue;
    //������������ִ��

    FDBConn := nil;
    with gParamManager.ActiveParam^ do
    try
      FDBConn := gDBConnManager.GetConnection(gDBConnManager.DefaultConnection, nErr);
      if not Assigned(FDBConn) then Continue;

      if FNumOutFactMsg = 0 then
      begin
        TBusWorkerBusinessHHJY.CallMe(cBC_GetLoginToken,
                    gSysParam.FWXZhangHu,gSysParam.FWXMiMa, @nOut);
        TBusWorkerBusinessHHJY.CallMe(cBC_GetSaleInfo,'','',@nOut);
      end;
      if FNumOutFactMsg = 300 then
      begin
        TBusWorkerBusinessHHJY.CallMe(cBC_GetLoginToken,
                    gSysParam.FWXZhangHu,gSysParam.FWXMiMa, @nOut);
        TBusWorkerBusinessHHJY.CallMe(cBC_GetOrderInfoEx,'','',@nOut);
      end;
      if FNumOutFactMsg = 600 then
      begin
        //ͬ��ʧ�ܺ������ϴ�
        UpdateSynFailedClear;
      end;

      nStr:= ' select top 100 *, H_PurType from %s where H_SyncNum <= %d And H_Deleted <> ''%s''';
      nStr:= Format(nStr,[sTable_HHJYSync, gMessageScan.FSyncTime, sFlag_Yes]);
      with gDBConnManager.WorkerQuery(FDBConn, nStr) do
      begin
        if RecordCount < 1 then
          Continue;
        //������Ϣ
        nSuccessCount := 0;
        nFailCount := 0;
        WriteLog('����ѯ��'+ IntToStr(RecordCount) + '������,��ʼ����...');
        nInit := GetTickCount;

        First;
        while not Eof do
        begin
        {$IFDEF UseWXERP}
          FListA.Clear;
          FListA.Values['ID']       := FieldByName('H_ID').AsString;
          FListA.Values['BillType'] := FieldByName('H_BillType').AsString;
          FListA.Values['PurType']  := FieldByName('H_PurType').AsString;
          FListA.Values['Status']   := FieldByName('H_Status').AsString;
          FListA.Values['Order']    := FieldByName('H_Order').AsString;

          UpdateMsgNumEx(False,FListA.Values['ID'],FListA.Values['PurType']);

          if  UpperCase(Trim(FListA.Values['BillType'])) = 'S' then
          begin
            WriteLog('���ͣ�'+ Trim(FListA.Values['PurType']));
            if UpperCase(Trim(FListA.Values['PurType'])) <> 'TRK' then
            begin
              TBusWorkerBusinessHHJY.CallMe(cBC_GetLoginToken,
                          gSysParam.FWXZhangHu,gSysParam.FWXMiMa, @nOut);
                          
              WriteLog('ִ��ͬ�����۰���');
              //ͬ�����۰���
              nResult := TBusWorkerBusinessHHJY.CallMe(cBC_GetSalePound,
                      FListA.Values['ID'], '', @nOut);

              TBusWorkerBusinessHHJY.CallMe(cBC_GetLoginToken,
                  gSysParam.FWXZhangHu,gSysParam.FWXMiMa, @nOut);

              TBusWorkerBusinessHHJY.CallMe(cBC_GetSaleTruckNum,
                      FListA.Values['Order'], '', @nOut);
              //��ȡ�ʼ���Ϣ 
               TBusWorkerBusinessHHJY.CallMe(cBC_GetHYInfo,
                      FListA.Values['ID'], '', @nOut);
            end
            else
            begin
              TBusWorkerBusinessHHJY.CallMe(cBC_GetLoginToken,
                  gSysParam.FWXZhangHu,gSysParam.FWXMiMa, @nOut);
              //���۶����������볡������
             nResult :=  TBusWorkerBusinessHHJY.CallMe(cBC_GetSaleTruckNum,
                      FListA.Values['Order'], '', @nOut);
            end;
          end
          else
          begin
            if Trim(FListA.Values['PurType']) <> 'Trk' then
            begin
              TBusWorkerBusinessHHJY.CallMe(cBC_GetLoginToken,
                        gSysParam.FWXZhangHu,gSysParam.FWXMiMa, @nOut);
              //ͬ���ɹ�����
              nResult := TBusWorkerBusinessHHJY.CallMe(cBC_GetOrderPound,
                      FListA.Values['ID'], '', @nOut);

              //�ɹ������������볡������
              TBusWorkerBusinessHHJY.CallMe(cBC_GetOrderTruckNum,
                      FListA.Values['Order'], '', @nOut);
            end
            else
            begin
              TBusWorkerBusinessHHJY.CallMe(cBC_GetLoginToken,
                  gSysParam.FWXZhangHu,gSysParam.FWXMiMa, @nOut);
              //�ɹ������������볡������
             nResult :=  TBusWorkerBusinessHHJY.CallMe(cBC_GetOrderTruckNum,
                      FListA.Values['Order'], '', @nOut);
            end;
          end;
          if nResult then
          begin
            //����Ϊ�Ѵ���
            Inc(nSuccessCount);
          end
          else
          begin
            Inc(nFailCount);
          end;

          UpdateMsgNumEx(nResult,FListA.Values['ID'],FListA.Values['PurType']);

          WriteLog('��'+IntToStr(RecNo)+'�����ݴ�����ɣ��������:'+FieldByName('H_ID').AsString);
          Next;
        {$ELSE}
          FListA.Clear;
          FListA.Values['ID']:= FieldByName('H_ID').AsString;
          FListA.Values['BillType']:= FieldByName('H_BillType').AsString;
          FListA.Values['Purype']:= FieldByName('H_PurType').AsString;
          FListA.Values['Status']:= FieldByName('H_Status').AsString;

          UpdateMsgNum(False,FListA.Values['ID']);

          nStr := PackerEncodeStr(FListA.Text);

          if FListA.Values['BillType'] = sFlag_Sale then
            nResult := TBusWorkerBusinessHHJY.CallMe(cBC_SyncHhSaleDetail
                       ,nStr,'',@nOut)
          else
          begin
            if FListA.Values['Purype'] = sFlag_PurND then
              nResult := TBusWorkerBusinessHHJY.CallMe(cBC_SyncHhNdOrderPoundData
                       ,nStr,'',@nOut)
            else
            if FListA.Values['Purype'] = sFlag_PurBP then
              nResult := TBusWorkerBusinessHHJY.CallMe(cBC_SyncHhOtOrderPoundData
                       ,nStr,'',@nOut)
            else
              nResult := TBusWorkerBusinessHHJY.CallMe(cBC_SyncHhOrderPoundData
                       ,nStr,'',@nOut);
          end;

          if nResult then
          begin
            //����Ϊ�Ѵ���
            Inc(nSuccessCount);
          end
          else
          begin
            Inc(nFailCount);
          end;

          UpdateMsgNumEx(nResult,FListA.Values['ID'],);
          WriteLog('��'+IntToStr(RecNo)+'�����ݴ�����ɣ��������:'+FListA.Values['ID']);
          Next;
        {$ENDIF}
        end;
      end;
      WriteLog(IntToStr(nSuccessCount) + '����Ϣͬ���ɹ���'
                + IntToStr(nFailCount) + '����Ϣͬ��ʧ�ܣ�'
                + '��ʱ: ' + IntToStr(GetTickCount - nInit) + 'ms');
    finally
      gDBConnManager.ReleaseConnection(FDBConn);
      FSyncLock.SyncLockLeave();
      WriteLog('Release FDBConn');
    end;
  except
    on E:Exception do
    begin
      WriteLog(E.Message);
    end;
  end;
end;

function TMessageScanThread.SendSaleMsgToWebMall(nList: TStrings):Boolean;
var nStr, nLID, nTableName: string;
    nDBWorker: PDBWorker;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;

  nLID := nList.Values['WOM_LID'];

  nDBWorker := nil;
  try
    nStr := 'Select L_ID,L_ZhiKa,L_CusID,L_CusName,L_Type,L_StockNo,' +
            'L_StockName,L_Truck,L_Value,L_Card,L_Price ' +
            'From $Bill b ';
    //xxxxx

    nStr := nStr + 'Where L_ID=''$CD''';

    if StrToIntDef(nList.Values['WOM_StatusType'],0) = c_WeChatStatusDeleted then
      nTableName := sTable_BillBak
    else
      nTableName := sTable_Bill;
    nStr := MacroValue(nStr, [MI('$Bill', nTableName), MI('$CD', nLID)]);
    //xxxxx

    with gDBConnManager.SQLQuery(nStr, nDBWorker) do
    begin
      if RecordCount < 1 then
      begin
        nStr := '������[ %s ]����Ч.';

        nStr := Format(nStr, [nLID]);
        WriteLog(nStr);
        Exit;
      end;

      First;

      while not Eof do
      begin
        FListB.Clear;

        FListB.Values['CusID']      := FieldByName('L_CusID').AsString;
        FListB.Values['MsgType']    := nList.Values['WOM_MsgType'];
        FListB.Values['BillID']     := FieldByName('L_ID').AsString;
        FListB.Values['Card']       := FieldByName('L_Card').AsString;
        FListB.Values['Truck']      := FieldByName('L_Truck').AsString;
        FListB.Values['StockNo']    := FieldByName('L_StockNo').AsString;
        FListB.Values['StockName']  := FieldByName('L_StockName').AsString;
        FListB.Values['CusName']    := FieldByName('L_CusName').AsString;
        FListB.Values['Value']      := FieldByName('L_Value').AsString;

        nStr := PackerEncodeStr(FListB.Text);

        Result := TBusWorkerBusinessWebchat.CallMe(cBC_WX_send_event_msg
           ,nStr,'',@nOut);
        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
end;

function TMessageScanThread.SendOrderMsgToWebMall(nList: TStrings):Boolean;
var nStr, nLID, nTableName: string;
    nDBWorker: PDBWorker;
    nOut: TWorkerBusinessCommand;
begin
  Result := False;

  nLID := nList.Values['WOM_LID'];

  nDBWorker := nil;
  try
    if StrToIntDef(nList.Values['WOM_StatusType'],0) = c_WeChatStatusFinished then
    begin
      nStr := 'Select D_ID,D_OID,D_ProID,D_ProName,D_Type,D_StockNo,' +
              'D_StockName,D_Truck,D_Value,D_Card ' +
              'From $Bill b ';
      //xxxxx

      nStr := nStr + 'Where D_OID=''$CD''';

      nTableName := sTable_OrderDtl;
      nStr := MacroValue(nStr, [MI('$Bill', nTableName), MI('$CD', nLID)]);
      //xxxxx
    end
    else
    begin
      nStr := 'Select O_ID as D_OID,O_ProID as D_ProID,O_ProName as D_ProName,'+
              'O_Type as D_Type,O_StockNo as D_StockNo,O_StockName as D_StockName,' +
              'O_Truck as D_Truck,O_Value as D_Value,O_Card as D_Card ' +
              'From $Bill b ';
      //xxxxx

      nStr := nStr + 'Where O_ID=''$CD''';

      if StrToIntDef(nList.Values['WOM_StatusType'],0) = c_WeChatStatusDeleted then
        nTableName := sTable_OrderBak
      else
        nTableName := sTable_Order;
      nStr := MacroValue(nStr, [MI('$Bill', nTableName), MI('$CD', nLID)]);
      //xxxxx
    end;

    with gDBConnManager.SQLQuery(nStr, nDBWorker) do
    begin
      if RecordCount < 1 then
      begin
        nStr := '�ɹ���[ %s ]����Ч.';

        nStr := Format(nStr, [nLID]);
        WriteLog(nStr);
        Exit;
      end;

      First;

      while not Eof do
      begin
        FListB.Clear;

        FListB.Values['CusID']      := FieldByName('D_ProID').AsString;
        FListB.Values['MsgType']    := nList.Values['WOM_MsgType'];
        FListB.Values['BillID']     := FieldByName('D_OID').AsString;
        FListB.Values['Card']       := FieldByName('D_Card').AsString;
        FListB.Values['Truck']      := FieldByName('D_Truck').AsString;
        FListB.Values['StockNo']    := FieldByName('D_StockNo').AsString;
        FListB.Values['StockName']  := FieldByName('D_StockName').AsString;
        FListB.Values['CusName']    := FieldByName('D_ProName').AsString;
        FListB.Values['Value']      := FieldByName('D_Value').AsString;

        nStr := PackerEncodeStr(FListB.Text);

        Result := TBusWorkerBusinessWebchat.CallMe(cBC_WX_send_event_msg
           ,nStr,'',@nOut);
        Next;
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBWorker);
  end;
end;

procedure TMessageScanThread.UpdateMsgNum(const nSuccess: Boolean; nLID: string);
var nStr: string;
    nUpdateDBWorker: PDBWorker;
begin
  if nSuccess then
  begin
    nUpdateDBWorker := nil;

    try
        nStr := 'Update %s set H_Deleted = ''%s'' where H_ID = ''%s''';
        nStr:= Format(nStr,[sTable_HHJYSync, sFlag_Yes,nLID]);
        gDBConnManager.ExecSQL(nStr);
        //����Ϊ�Ѵ���
    finally
      gDBConnManager.ReleaseConnection(nUpdateDBWorker);
    end;
  end
  else
  begin
    nUpdateDBWorker := nil;

    try
      nStr := 'Update %s Set H_SyncNum = H_SyncNum + 1 '+
                ' where H_ID = ''%s''';
      nStr:= Format(nStr,[sTable_HHJYSync, nLID]);
      gDBConnManager.ExecSQL(nStr);
    finally
      gDBConnManager.ReleaseConnection(nUpdateDBWorker);
    end;
  end;
end;

procedure TMessageScanThread.DoSaveOutFactMsg;
var nStr: string;
    nInit: Int64;
    nErr,nIdx: Integer;
    nOut: TWorkerWebChatData;
begin
  nStr:= 'select top 100 * from %s where WOM_StatusType =%d Order by R_ID desc';
  nStr:= Format(nStr,[sTable_WebOrderMatch, c_WeChatStatusCreateCard]);
  //��ѯ���100�����Ͽ�����¼
  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount < 1 then
      Exit;
    //������Ϣ
    WriteLog('����ѯ��'+ IntToStr(RecordCount) + '������,��ʼɸѡ...');
    nInit := GetTickCount;
    FListB.Clear;

    First;

    while not Eof do
    begin
      FListA.Clear;
      FListA.Values['WOM_WebOrderID'] := FieldByName('WOM_WebOrderID').AsString;
      FListA.Values['WOM_LID']:= FieldByName('WOM_LID').AsString;
      FListA.Values['WOM_StatusType']:= FieldByName('WOM_StatusType').AsString;
      FListA.Values['WOM_MsgType']:= FieldByName('WOM_MsgType').AsString;
      FListA.Values['WOM_BillType']:= FieldByName('WOM_BillType').AsString;
      nStr := StringReplace(FListA.Text, #$D#$A, '\S', [rfReplaceAll]);
      FListB.Add(nStr);
      Next;
    end;
  end;
  for nIdx := 0 to FListB.Count - 1 do
  begin
    nStr := FListB.Strings[nIdx];
    FListA.Text := StringReplace(nStr, '\S', #$D#$A, [rfReplaceAll]);
    if FListA.Values['WOM_BillType'] = sFlag_Sale then
      SaveSaleOutFactMsg(FListA)
    else
      SaveOrderOutFactMsg(FListA);
  end;
  WriteLog('�������������Ϣ��ʱ: ' + IntToStr(GetTickCount - nInit) + 'ms');
end;

function TMessageScanThread.SaveSaleOutFactMsg(nList: TStrings): Boolean;
var nStr, nLID, nTableName: string;
begin
  Result := False;
  nLID := nList.Values['WOM_LID'];

  nStr := 'select L_ID from %s where L_ID=''%s'' and L_OutFact is not null ';
  nStr := Format(nStr,[sTable_Bill,nLID]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount <= 0 then
    begin
      Exit;
    end;
  end;

  nStr := 'select WOM_LID from %s where WOM_LID=''%s'' and WOM_StatusType=%d ';
  nStr := Format(nStr,[sTable_WebOrderMatch,nLID,c_WeChatStatusFinished]);
  //xxxxx

  with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount >= 1 then
    begin
      Exit;
    end;
  end;

  WriteLog('��ѯ�������'+ nLID +'�ѳ���,����������Ϣ...');

  nStr := 'insert into %s(WOM_WebOrderID,WOM_LID,WOM_StatusType,WOM_MsgType,WOM_BillType)'
          + ' values(''%s'',''%s'',%d,%d,''%s'')';
  nStr := Format(nStr,[sTable_WebOrderMatch,nList.Values['WOM_WebOrderID'],
                       nLID,c_WeChatStatusFinished,cSendWeChatMsgType_OutFactory,
                       nList.Values['WOM_BillType']]);
  gDBConnManager.WorkerExec(FDBConn, nStr);
  Result := True;
end;

function TMessageScanThread.SaveOrderOutFactMsg(nList: TStrings): Boolean;
var nStr, nLID, nTableName: string;
begin
  Result := False;
  nLID := nList.Values['WOM_LID'];

  nStr := 'select D_ID from %s where D_OID=''%s'' and D_OutFact is not null ';
  nStr := Format(nStr,[sTable_OrderDtl,nLID]);
  //xxxxx

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount <= 0 then
    begin
      Exit;
    end;
  end;

  nStr := 'select WOM_LID from %s where WOM_LID=''%s'' and WOM_StatusType=%d ';
  nStr := Format(nStr,[sTable_WebOrderMatch,nLID,c_WeChatStatusFinished]);
  //xxxxx

    with gDBConnManager.WorkerQuery(FDBConn, nStr) do
  begin
    if RecordCount >= 1 then
    begin
      Exit;
    end;
  end;

  WriteLog('��ѯ���ɹ���'+ nLID +'�ѳ���,����������Ϣ...');

  nStr := 'insert into %s(WOM_WebOrderID,WOM_LID,WOM_StatusType,WOM_MsgType,WOM_BillType)'
          + ' values(''%s'',''%s'',%d,%d,''%s'')';
  nStr := Format(nStr,[sTable_WebOrderMatch,nList.Values['WOM_WebOrderID'],
                       nLID,c_WeChatStatusFinished,cSendWeChatMsgType_OutFactory,
                       nList.Values['WOM_BillType']]);
  gDBConnManager.WorkerExec(FDBConn, nStr);
  Result := True;
end;

procedure TMessageScanThread.UpdateMsgNumEx(const nSuccess: Boolean; nLID,
  nPurType: string);
var nStr: string;
    nUpdateDBWorker: PDBWorker;
begin
  if nSuccess then
  begin
    nUpdateDBWorker := nil;

    try
        nStr := 'Update %s set H_Deleted = ''%s'' where H_ID = ''%s'' and H_PurType = ''%s'' ';
        nStr:= Format(nStr,[sTable_HHJYSync, sFlag_Yes,nLID,nPurType]);
        gDBConnManager.ExecSQL(nStr);
        //����Ϊ�Ѵ���
    finally
      gDBConnManager.ReleaseConnection(nUpdateDBWorker);
    end;
  end
  else
  begin
    nUpdateDBWorker := nil;

    try
      nStr := 'Update %s Set H_SyncNum = H_SyncNum + 1 '+
                ' where H_ID = ''%s'' and H_PurType = ''%s'' ';
      nStr:= Format(nStr,[sTable_HHJYSync, nLID, nPurType]);
      gDBConnManager.ExecSQL(nStr);
    finally
      gDBConnManager.ReleaseConnection(nUpdateDBWorker);
    end;
  end;
end;

procedure TMessageScanThread.UpdateSynFailedClear;
var nStr: string;
    nUpdateDBWorker: PDBWorker;
begin
  nUpdateDBWorker := nil;
  try
    nStr := ' Update %s set H_FailedNum = H_FailedNum + 1,  H_SyncNum = 0 '
           +' where H_Deleted = ''N'' and H_FailedNum <= 10 and H_SyncNum > 5  ';
    nStr:= Format(nStr,[sTable_HHJYSync]);
    gDBConnManager.ExecSQL(nStr);
    //����Ϊ�Ѵ���
  finally
    gDBConnManager.ReleaseConnection(nUpdateDBWorker);
  end;
end;

initialization
  gMessageScan := nil;
finalization
  FreeAndNil(gMessageScan);
end.

