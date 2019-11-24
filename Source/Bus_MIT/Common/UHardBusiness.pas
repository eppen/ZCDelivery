{*******************************************************************************
  ����: dmzn@163.com 2012-4-22
  ����: Ӳ������ҵ��
*******************************************************************************}
unit UHardBusiness;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, SysUtils, UMgrDBConn, UMgrParam, DB,
  UBusinessWorker, UBusinessConst, UBusinessPacker, UMgrQueue,
  {$IFDEF MultiReplay}UMultiJS_Reply, {$ELSE}UMultiJS, {$ENDIF}
  UMgrHardHelper, U02NReader, UMgrERelay, UMgrRemotePrint,UMgrSendCardNo,
  {$IFDEF UseLBCModbus}UMgrLBCModusTcp, {$ENDIF}
  UMgrLEDDisp, UMgrRFID102, UMgrTTCEM100, UMgrVoiceNet, UMgrremoteSnap,
  uSuperObject,MsMultiPartFormData,IdHTTP;

procedure WhenReaderCardArrived(const nReader: THHReaderItem);
procedure WhenHYReaderCardArrived(const nReader: PHYReaderItem);
//���¿��ŵ����ͷ
procedure WhenReaderCardIn(const nCard: string; const nHost: PReaderHost);
//�ֳ���ͷ���¿���
procedure WhenReaderCardOut(const nCard: string; const nHost: PReaderHost);
//�ֳ���ͷ���ų�ʱ
procedure WhenTTCE_M100_ReadCard(const nItem: PM100ReaderItem);
//Ʊ�������
procedure WhenBusinessMITSharedDataIn(const nData: string);
//ҵ���м����������
function GetJSTruck(const nTruck,nBill: string): string;
//��ȡ��������ʾ����
procedure WhenSaveJS(const nTunnel: PMultiJSTunnel);
//����������
function VerifySnapTruck(const nTruck,nBill,nPos: string;var nResult: string): Boolean;
//����ʶ��
procedure MakeGateSound(const nText,nPost: string; const nSucc: Boolean);
//�����Ÿ�����
procedure PlayNetVoice(const nText,nPost: string);
{$IFDEF UseLBCModbus}
procedure WhenLBCWeightStatusChange(const nTunnel: PLBTunnel);
//����Ӷ���װ��״̬�ı�
{$ENDIF}

implementation

uses
  ULibFun, USysDB, USysLoger, UTaskMonitor, UFormCtrl, UMITConst;

const
  sPost_In   = 'in';
  sPost_Out  = 'out';
  sPost_ZT   = 'zt';
  sPost_FH   = 'fh';

var
  Ftoken : string;

//Date: 2014-09-15
//Parm: ����;����;����;���
//Desc: ���ص���ҵ�����
function CallBusinessCommand(const nCmd: Integer;
  const nData, nExt: string; const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerBusinessCommand;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessCommand);
    //get worker

    Result := nWorker.WorkActive(nStr);
    if Result then
         nPacker.UnPackOut(nStr, nOut)
    else nOut.FData := nStr;
  finally
    gBusinessPackerManager.RelasePacker(nPacker);
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2014-09-05
//Parm: ����;����;����;���
//Desc: �����м���ϵ����۵��ݶ���
function CallBusinessSaleBill(const nCmd: Integer;
  const nData, nExt: string; const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerBusinessCommand;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessSaleBill);
    //get worker

    Result := nWorker.WorkActive(nStr);
    if Result then
         nPacker.UnPackOut(nStr, nOut)
    else nOut.FData := nStr;
  finally
    gBusinessPackerManager.RelasePacker(nPacker);
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2015-08-06
//Parm: ����;����;����;���
//Desc: �����м���ϵ����۵��ݶ���
function CallBusinessPurchaseOrder(const nCmd: Integer;
  const nData, nExt: string; const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerBusinessCommand;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessPurchase);
    //get worker

    Result := nWorker.WorkActive(nStr);
    if Result then
         nPacker.UnPackOut(nStr, nOut)
    else nOut.FData := nStr;
  finally
    gBusinessPackerManager.RelasePacker(nPacker);
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2014-10-16
//Parm: ����;����;����;���
//Desc: ����Ӳ���ػ��ϵ�ҵ�����
function CallHardwareCommand(const nCmd: Integer;
  const nData, nExt: string; const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerBusinessCommand;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessCommand);
    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_HardwareCommand);
    //get worker

    Result := nWorker.WorkActive(nStr);
    if Result then
         nPacker.UnPackOut(nStr, nOut)
    else nOut.FData := nStr;
  finally
    gBusinessPackerManager.RelasePacker(nPacker);
    gBusinessWorkerManager.RelaseWorker(nWorker);
  end;
end;

//Date: 2012-3-23
//Parm: �ſ���;��λ;�������б�
//Desc: ��ȡnPost��λ�ϴſ�ΪnCard�Ľ������б�
function GetLadingBills(const nCard,nPost: string;
 var nData: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessSaleBill(cBC_GetPostBills, nCard, nPost, @nOut);
  if Result then
       AnalyseBillItems(nOut.FData, nData)
  else gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
end;

//Date: 2014-09-18
//Parm: ��λ;�������б�
//Desc: ����nPost��λ�ϵĽ���������
function SaveLadingBills(const nPost: string; nData: TLadingBillItems): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessSaleBill(cBC_SavePostBills, nStr, nPost, @nOut);

  if not Result then
    gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
  //xxxxx
end;

//Date: 2015-08-06
//Parm: �ſ���
//Desc: ��ȡ�ſ�ʹ������
function GetCardUsed(const nCard: string; var nCardType: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_GetCardUsed, nCard, '', @nOut);

  if Result then
       nCardType := nOut.FData
  else gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
  //xxxxx
end;

//Date: 2019-06-15
//Parm: �������
//Desc: ǿ��˳��װ��ʱУ��ǰ��״̬
function VerifyTruckStatus(const nLID, nNowTruck: string; var nHint: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_VerifyTruckStatus, nLID, nNowTruck, @nOut);
end;

function VeryTruckLicense(const nTruck, nBill: string; var nMsg: string): Boolean;
var
  nList: TStrings;
  nOut: TWorkerBusinessCommand;
  nID : string;
begin
  if nBill = '' then
    nID := nTruck + FormatDateTime('YYMMDD',Now)
  else
    nID := nBill;

  nList := nil;
  try
    nList := TStringList.Create;
    nList.Values['Truck'] := nTruck;
    nList.Values['Bill'] := nID;

    Result := CallBusinessCommand(cBC_VeryTruckLicense, nList.Text, '', @nOut);
    nMsg := nOut.FData
  finally
    nList.Free;
  end;
end;

//Date: 2015-08-06
//Parm: �ſ���;��λ;�ɹ����б�
//Desc: ��ȡnPost��λ�ϴſ�ΪnCard�Ľ������б�
function GetLadingOrders(const nCard,nPost: string;
 var nData: TLadingBillItems): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessPurchaseOrder(cBC_GetPostOrders, nCard, nPost, @nOut);
  if Result then
       AnalyseBillItems(nOut.FData, nData)
  else gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
end;

//Date: 2015-08-06
//Parm: ��λ;�ɹ����б�
//Desc: ����nPost��λ�ϵĲɹ�������
function SaveLadingOrders(const nPost: string; nData: TLadingBillItems): Boolean;
var nStr: string;
    nOut: TWorkerBusinessCommand;
begin
  nStr := CombineBillItmes(nData);
  Result := CallBusinessPurchaseOrder(cBC_SavePostOrders, nStr, nPost, @nOut);

  if not Result then
    gSysLoger.AddLog(TBusinessWorkerManager, 'ҵ�����', nOut.FData);
  //xxxxx
end;
                                                             
//------------------------------------------------------------------------------
//Date: 2013-07-21
//Parm: �¼�����;��λ��ʶ
//Desc:
procedure WriteHardHelperLog(const nEvent: string; nPost: string = '');
begin
  gDisplayManager.Display(nPost, nEvent);
  gSysLoger.AddLog(THardwareHelper, 'Ӳ���ػ�����', nEvent);
end;

procedure BlueOpenDoor(const nReader: string);
var nIdx: Integer;
begin
  nIdx := 0;
  if nReader <> '' then
  while nIdx < 3 do
  begin
    if gHardwareHelper.ConnHelper then
         gHardwareHelper.OpenDoor(nReader)
    else gHYReaderManager.OpenDoor(nReader);

    Inc(nIdx);
  end;
end;

//Date: 2017-10-16
//Parm: ����;��λ;ҵ��ɹ�
//Desc: �����Ÿ�����
procedure MakeGateSound(const nText,nPost: string; const nSucc: Boolean);
var nStr: string;
    nInt: Integer;
begin
  try
    if nSucc then
         nInt := 2
    else nInt := 3;

    gHKSnapHelper.Display(nPost, nText, nInt);
    //С����ʾ

    gNetVoiceHelper.PlayVoice(nText, nPost);
    //��������
    WriteHardHelperLog(nText);
  except
    on nErr: Exception do
    begin
      nStr := '����[ %s ]����ʧ��,����: %s';
      nStr := Format(nStr, [nPost, nErr.Message]);
      WriteHardHelperLog(nStr);
    end;
  end;
end;

//Date: 2019-07-09
//Parm: ����;��λ
//Desc: ��������
procedure PlayNetVoice(const nText,nPost: string);
var nStr: string;
begin
  try
    gNetVoiceHelper.PlayVoice(nText, nPost);
    //��������
    WriteHardHelperLog(nText);
  except
    on nErr: Exception do
    begin
      nStr := '����[ %s ]����ʧ��,����: %s';
      nStr := Format(nStr, [nPost, nErr.Message]);
      WriteHardHelperLog(nStr);
    end;
  end;
end;

//Date: 2018-04-03
//Parm: ë��ʱ��
//Desc: ��ȡ�ſ�ʹ������
function IsTruckTimeOut(const nMDate: string): Boolean;
var nOut: TWorkerBusinessCommand;
begin
  Result := CallBusinessCommand(cBC_TruckTimeOut, nMDate, '', @nOut);
  //xxxxx
end;

function UnicodeToChinese(inputstr: string): string;
var
    i: Integer;
    index: Integer;
    temp, top, last: string;
begin
    index := 1;
    while index >= 0 do
    begin
        index := Pos('\u', inputstr) - 1;
        if index < 0 then
        begin
            last := inputstr;
            Result := Result + last;
            Exit;
        end;
        top := Copy(inputstr, 1, index); // ȡ�� �����ַ�ǰ�� �� unic ������ַ���������
        temp := Copy(inputstr, index + 1, 6); // ȡ�����룬���� \u,��\u4e3f
        Delete(temp, 1, 2);
        Delete(inputstr, 1, index + 6);
        Result := Result + top + WideChar(StrToInt('$' + temp));
    end;
end;

//��ȡ����״̬�Ƿ�ر�
function GetSaleInfo_One(const nOrderNo: string): Boolean;
var nStr, nProStr, nMatStr, nYearStr,nSQL: string;
    nO_Valid, nStockName : string;
    nValue: Double;
    nYearMonth, szUrl, nType : string;
    ReJo, OneJo : ISuperObject;
    ArrsJa,ArrsJaSub: TSuperArray;
    ReStream:TStringstream;
    nYear, nMonth, nDays : Word;
    nDataStream: TMsMultiPartFormDataStream;
    nOut: TWorkerBusinessCommand;
    nOrderName:string;
    FListA: TStrings;
    FIdHttp : TIdHTTP;
function GetLoginToken: Boolean;
var
  nStr, szUrl: string;
  ReJo, ReSubJo : ISuperObject;
  ArrsJa: TSuperArray;
  wParam: TStrings;
  ReStream:TStringstream;
begin
  Result   := False;
  wParam   := TStringList.Create;
  ReStream := TStringstream.Create('');

  try
    wParam.Clear;
    wParam.Values['username'] := gSysParam.FWXZhangHu;
    wParam.Values['password'] := gSysParam.FWXMiMa;

    szUrl := gSysParam.FWXERPUrl+'/login';
    FidHttp.Request.ContentType := 'application/x-www-form-urlencoded';
    FidHttp.Post(szUrl, wParam, ReStream);
    nStr := ReStream.DataString;
    nStr := UTF8Decode(ReStream.DataString);
    nStr := UnicodeToChinese(nStr);

    if nStr <> '' then
    begin
      ReJo    := SO(nStr);
      ReSubJo := SO(ReJo.S['Response']);
      if ReSubJo.S['token'] <> '' then
      begin
        Ftoken := ReSubJo.S['token'];
        Result := True;
      end
      else
      begin
        Result := False;
      end;
    end;
  finally
    ReStream.Free;
    wParam.Free;
  end;
end;
begin
  Result := True;

  FidHttp                := TIdHTTP.Create(nil);
  FidHttp.ConnectTimeout := 10 * 1000;
  FidHttp.ReadTimeout    := 10 * 1000;

  FListA      := TStringList.Create;
  ReStream    := TStringstream.Create('');
  nDataStream := TMsMultiPartFormDataStream.Create;

  try
    if GetLoginToken then
    begin
      nDataStream.AddFormField('token', Ftoken);
      nDataStream.AddFormField('starttime', DateTime2Str(IncMonth(Now,-12)));
      nDataStream.AddFormField('ordername', Ansitoutf8(nOrderNo));
      nDataStream.AddFormField('endtime', DateTime2Str(Now) + CRLF);
      nDataStream.done;

      szUrl := gSysParam.FWXERPUrl + '/saleorder';
      FIdHttp.HTTPOptions:=FIdHttp.HTTPOptions+[hoKeepOrigProtocol];
      FidHttp.ProtocolVersion:= pv1_1;
      FidHttp.Request.ContentType := nDataStream.RequestContentType;
      FidHttp.Post(szUrl, nDataStream, ReStream);
      nStr := ReStream.DataString;
      nStr := UTF8Decode(ReStream.DataString);
      nStr := UnicodeToChinese(nStr);

      FListA.Clear;
      if nStr <> '' then
      begin
        ReJo    := SO(nStr);
        ReJo    := SO(ReJo.S['Response']);
        ArrsJa  := ReJo.A['Infos'];
        if ArrsJa <> nil then
        begin
          if ArrsJa.Length = 0 then
          begin
            Result  := False;
            Exit;
          end
          else
          begin
            OneJo := SO(ArrsJa.S[0]);

            if OneJo.B['is_closed'] then
              Result := False
            else
              Result := True;
          end;
        end
        else
        begin
          Result  := False;
        end;
      end;
    end
    else
    begin
      Result := True;
    end;
  finally
    ReStream.Free;
    nDataStream.Free;
    FreeAndNil(FidHttp);
  end;
end;

//Date: 2012-4-22
//Parm: ����
//Desc: ��nCard���н���
procedure MakeTruckIn(const nCard,nReader: string; const nDB: PDBWorker);
var nStr,nTruck,nCardType,nSnapStr: string;
    nIdx,nInt: Integer;
    nPLine: PLineItem;
    nPTruck: PTruckItem;
    nTrucks: TLadingBillItems;
    nRet: Boolean;
    nMsg: string;
begin
  if gTruckQueueManager.IsTruckAutoIn and (GetTickCount -
     gHardwareHelper.GetCardLastDone(nCard, nReader) < 2 * 60 * 1000) then
  begin
    gHardwareHelper.SetReaderCard(nReader, nCard);
    Exit;
  end; //ͬ��ͷͬ��,��2�����ڲ������ν���ҵ��.

  nCardType := '';
  if not GetCardUsed(nCard, nCardType) then Exit;

  if (nCardType = sFlag_Provide) or (nCardType = sFlag_Mul) then
        nRet := GetLadingOrders(nCard, sFlag_TruckIn, nTrucks)
  else  nRet := GetLadingBills(nCard, sFlag_TruckIn, nTrucks);

  if not nRet then
  begin
    nStr := '��ȡ�ſ�[ %s ]������Ϣʧ��.';
    nStr := Format(nStr, [nCard]);
    WriteHardHelperLog(nStr, sPost_In);

    nStr := '��ȡ�ſ���Ϣʧ��';

    {$IFNDEF NoUsePlayVoice}
    MakeGateSound(nStr, sPost_In, False);
    {$ENDIF}
    
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '�ſ�[ %s ]û����Ҫ��������.';
    nStr := Format(nStr, [nCard]);
    WriteHardHelperLog(nStr, sPost_In);

    nStr := '���ȵ���Ʊ�Ұ���ҵ��';

    {$IFNDEF NoUsePlayVoice}
    MakeGateSound(nStr, sPost_In, False);
    {$ENDIF}
    
    Exit;
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    {$IFDEF UseOneTruckIn}
      if FStatus = sFlag_TruckNone then Continue;
      //δ����
    {$ELSE}
    if (FStatus = sFlag_TruckNone) or (FStatus = sFlag_TruckIn) then Continue;
    //δ����,���ѽ���
    {$ENDIF}

    nStr := '����[ %s ]��һ״̬Ϊ:[ %s ],����ˢ����Ч.';
    nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);
    WriteHardHelperLog(nStr, sPost_In);

    nStr := '����[ %s ]���ܽ���,Ӧ��ȥ[ %s ]';
    nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);

    {$IFNDEF NoUsePlayVoice}
    MakeGateSound(nStr, sPost_In, False);
    {$ENDIF}
    
    Exit;
  end;

  {$IFDEF RemoteSnap}
  if nCardType = sFlag_Sale then
  begin
    if not VerifySnapTruck(nTrucks[0].FTruck,nTrucks[0].FID,sPost_In,nSnapStr) then
    begin
      MakeGateSound(nSnapStr, sPost_In, False);
      Exit;
    end;
  end;
  {$ENDIF}

  {$IFDEF UseEnableStruck}
  if nTrucks[0].FStatus = sFlag_TruckNone then
  if not VeryTruckLicense(nTrucks[0].FTruck,nTrucks[0].FID, nMsg) then
  begin
    WriteHardHelperLog(nMsg, sPost_In);
    Exit;
  end;
  nStr := nMsg + ',�����';
  WriteHardHelperLog(nMsg, sPost_In);
  {$ENDIF}

  if nTrucks[0].FStatus = sFlag_TruckIn then
  begin
    if gTruckQueueManager.IsTruckAutoIn then
    begin
      gHardwareHelper.SetCardLastDone(nCard, nReader);
      gHardwareHelper.SetReaderCard(nReader, nCard);
    end else
    begin
      if gTruckQueueManager.TruckReInfactFobidden(nTrucks[0].FTruck) then
      begin
        BlueOpenDoor(nReader);
        //̧��

        nStr := '����[ %s ]�ٴ�̧�˲���.';
        nStr := Format(nStr, [nTrucks[0].FTruck]);
        WriteHardHelperLog(nStr, sPost_In);

        nStr := nSnapStr + ',�����';
        MakeGateSound(nStr, sPost_In, True);
      end;
    end;

    Exit;
  end;

  if (nCardType = sFlag_Provide) or (nCardType = sFlag_Mul) then
  begin
    if not SaveLadingOrders(sFlag_TruckIn, nTrucks) then
    begin
      nStr := '����[ %s ]��������ʧ��.';
      nStr := Format(nStr, [nTrucks[0].FTruck]);

      WriteHardHelperLog(nStr, sPost_In);
      Exit;
    end;

    if gTruckQueueManager.IsTruckAutoIn then
    begin
      gHardwareHelper.SetCardLastDone(nCard, nReader);
      gHardwareHelper.SetReaderCard(nReader, nCard);
    end else
    begin
      BlueOpenDoor(nReader);
      //̧��
    end;

    nStr := 'ԭ���Ͽ�[%s]����̧�˳ɹ�';
    nStr := Format(nStr, [nCard]);
    WriteHardHelperLog(nStr, sPost_In);
    Exit;
  end;
  //�ɹ��ſ�ֱ��̧��

  {$IFDEF UseWXERP}
    if not GetSaleInfo_One(nTrucks[0].FZhiKa) then
    begin
      nStr := '��ͬ����[ %s ]�ѱ��ر�,���ܽ������.';
      nStr := Format(nStr, [nTrucks[0].FZhiKa]);
      WriteHardHelperLog(nStr, sPost_In);
      Exit;
    end;
  {$ENDIF}

  nPLine := nil;
  //nPTruck := nil;

  with gTruckQueueManager do
  if not IsDelayQueue then //����ʱ����(����ģʽ)
  try
    SyncLock.Enter;
    nStr := nTrucks[0].FTruck;

    for nIdx:=Lines.Count - 1 downto 0 do
    begin
      nInt := TruckInLine(nStr, PLineItem(Lines[nIdx]).FTrucks);
      if nInt >= 0 then
      begin
        nPLine := Lines[nIdx];
        //nPTruck := nPLine.FTrucks[nInt];
        Break;
      end;
    end;

    if not Assigned(nPLine) then
    begin
      nStr := '����[ %s ]û���ڵ��ȶ�����.';
      nStr := Format(nStr, [nTrucks[0].FTruck]);
      WriteHardHelperLog(nStr, sPost_In);

      {$IFNDEF NoUsePlayVoice}
      nStr := '����[ %s ]���ܽ���,����ϵ������Ա.';
      nStr := Format(nStr, [nTrucks[0].FTruck]);
      MakeGateSound(nStr, sPost_In, False);
      {$ENDIF}

      Exit;
    end;
  finally
    SyncLock.Leave;
  end;

  if not SaveLadingBills(sFlag_TruckIn, nTrucks) then
  begin
    nStr := '����[ %s ]��������ʧ��.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteHardHelperLog(nStr, sPost_In);
    Exit;
  end;

  nStr := nSnapStr + ',�����';
  MakeGateSound(nStr, sPost_In, True);

  if gTruckQueueManager.IsTruckAutoIn then
  begin
    gHardwareHelper.SetCardLastDone(nCard, nReader);
    gHardwareHelper.SetReaderCard(nReader, nCard);
  end else
  begin
    BlueOpenDoor(nReader);
    //̧��
  end;

  with gTruckQueueManager do
  if not IsDelayQueue then //����ģʽ,����ʱ�󶨵���(һ���൥)
  try
    SyncLock.Enter;
    nTruck := nTrucks[0].FTruck;

    for nIdx:=Lines.Count - 1 downto 0 do
    begin
      nPLine := Lines[nIdx];
      nInt := TruckInLine(nTruck, PLineItem(Lines[nIdx]).FTrucks);

      if nInt < 0 then Continue;
      nPTruck := nPLine.FTrucks[nInt];

      nStr := 'Update %s Set T_Line=''%s'',T_PeerWeight=%d Where T_Bill=''%s''';
      nStr := Format(nStr, [sTable_ZTTrucks, nPLine.FLineID, nPLine.FPeerWeight,
              nPTruck.FBill]);
      //xxxxx

      gDBConnManager.WorkerExec(nDB, nStr);
      //��ͨ��
    end;
  finally
    SyncLock.Leave;
  end;
end;

//Date: 2012-4-22
//Parm: ����;��ͷ;��ӡ��;���鵥��ӡ��
//Desc: ��nCard���г���
function MakeTruckOut(const nCard,nReader,nPrinter: string;
 const nHYPrinter: string = ''): Boolean;
var nStr,nCardType: string;
    nIdx: Integer;
    nRet: Boolean;
    nTrucks: TLadingBillItems;
begin
  Result := False;
  if not GetCardUsed(nCard, nCardType) then
    nCardType := sFlag_Sale;
  //xxxxx

  if (nCardType = sFlag_Provide) or (nCardType = sFlag_Mul) then
        nRet := GetLadingOrders(nCard, sFlag_TruckOut, nTrucks)
  else  nRet := GetLadingBills(nCard, sFlag_TruckOut, nTrucks);

  if not nRet then
  begin
    Result := True;
    nStr := '��ȡ�ſ�[ %s ]������Ϣʧ��.�̿����̿�';
    nStr := Format(nStr, [nCard]);
    WriteHardHelperLog(nStr, sPost_Out);
    
    {$IFNDEF NoUsePlayVoice}
    nStr := '��ȡ�ſ���Ϣʧ��';
    MakeGateSound(nStr, sPost_Out, False);
    {$ENDIF}

    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '�ſ�[ %s ]û����Ҫ��������.';
    nStr := Format(nStr, [nCard]);
    WriteHardHelperLog(nStr, sPost_Out);

    {$IFNDEF NoUsePlayVoice}
    nStr := '���ȵ���Ʊ�Ұ���ҵ��';
    MakeGateSound(nStr, sPost_Out, False);
    {$ENDIF}
    
    Exit;
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    {$IFDEF TruckOutTimeOut}
    if (FType = sFlag_San) and (nCardType = sFlag_Sale) and
       (FStatus = sFlag_TruckFH) then //ɢװ��ι���
    begin
      if IsTruckTimeOut(FID) then
      begin
        nStr := '����[ %s ]������ʱ,�����¹���.';
        nStr := Format(nStr, [FTruck]);
        WriteHardHelperLog(nStr, sPost_Out);
        Exit;
      end;
      Continue;
    end;
    {$ENDIF}

    if FNextStatus = sFlag_TruckOut then Continue;
	//xxxxx

    nStr := '����[ %s ]��һ״̬Ϊ:[ %s ],�޷�����.';
    nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);
    WriteHardHelperLog(nStr, sPost_Out);

    {$IFNDEF NoUsePlayVoice}
    nStr := '����[ %s ]���ܳ���,Ӧ��ȥ[ %s ]';
    nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);
    MakeGateSound(nStr, sPost_Out, False);
    {$ENDIF}

    Exit;
  end;

  if (nCardType = sFlag_Provide) or (nCardType = sFlag_Mul) then
        nRet := SaveLadingOrders(sFlag_TruckOut, nTrucks)
  else  nRet := SaveLadingBills(sFlag_TruckOut, nTrucks);

  if not nRet then
  begin
    nStr := '����[ %s ]��������ʧ��.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteHardHelperLog(nStr, sPost_Out);
    Exit;
  end;

  if nReader <> '' then
    BlueOpenDoor(nReader);
  //̧��

  nStr := '����[ %s ]�����,��ӭ���������.';
  nStr := Format(nStr, [nTrucks[0].FTruck]);

  {$IFNDEF NoUsePlayVoice}
  MakeGateSound(nStr, sPost_Out, True);
  {$ENDIF}

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  begin
    if (nCardType = sFlag_Provide) or (nCardType = sFlag_Mul) then
    begin
      if not nTrucks[nIdx].FPrintBD then
        Continue;
    end;

//    if nCardType = sFlag_Sale then
//    begin
//      if nTrucks[nIdx].FYSValid = sFlag_Yes then//�ճ���������ӡ
//        Continue;
//    end;

    nStr := #7 + nCardType;
    //�ſ�����
    if nCardType = sFlag_Sale then
    begin
      if nTrucks[nIdx].FPrintHY and (nTrucks[nIdx].FYSValid <> sFlag_Yes) then
      begin
        if nHYPrinter <> '' then
          nStr := nStr + #6 + nHYPrinter;
        //���鵥��ӡ��
      end;
    end;

    if nPrinter = '' then
         gRemotePrinter.PrintBill(nTrucks[nIdx].FID + nStr)
    else gRemotePrinter.PrintBill(nTrucks[nIdx].FID + #9 + nPrinter + nStr);

  end; //��ӡ����

  Result := True;
end;

//Date: 2012-10-19
//Parm: ����;��ͷ
//Desc: ��⳵���Ƿ��ڶ�����,�����Ƿ�̧��
procedure MakeTruckPassGate(const nCard,nReader: string; const nDB: PDBWorker);
var nStr: string;
    nIdx: Integer;
    nTrucks: TLadingBillItems;
begin
  if not GetLadingBills(nCard, sFlag_TruckOut, nTrucks) then
  begin
    nStr := '��ȡ�ſ�[ %s ]��������Ϣʧ��.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '�ſ�[ %s ]û����Ҫͨ����բ�ĳ���.';
    nStr := Format(nStr, [nCard]);

    WriteHardHelperLog(nStr);
    Exit;
  end;

  if gTruckQueueManager.TruckInQueue(nTrucks[0].FTruck) < 0 then
  begin
    nStr := '����[ %s ]���ڶ���,��ֹͨ����բ.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteHardHelperLog(nStr);
    Exit;
  end;

  BlueOpenDoor(nReader);
  //̧��

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  begin
    nStr := 'Update %s Set T_InLade=%s Where T_Bill=''%s'' And T_InLade Is Null';
    nStr := Format(nStr, [sTable_ZTTrucks, sField_SQLServer_Now, nTrucks[nIdx].FID]);

    gDBConnManager.WorkerExec(nDB, nStr);
    //�������ʱ��,�������򽫲��ٽк�.
  end;
end;

//Date: 2012-4-22
//Parm: ��ͷ����
//Desc: ��nReader�����Ŀ��������嶯��
procedure WhenReaderCardArrived(const nReader: THHReaderItem);
var nStr,nCard: string;
    nErrNum: Integer;
    nDBConn: PDBWorker;
begin
  nDBConn := nil;
  {$IFDEF DEBUG}
  WriteHardHelperLog('WhenReaderCardArrived����.');
  {$ENDIF}

  with gParamManager.ActiveParam^ do
  try
    nDBConn := gDBConnManager.GetConnection(FDB.FID, nErrNum);
    if not Assigned(nDBConn) then
    begin
      WriteHardHelperLog('����HM���ݿ�ʧ��(DBConn Is Null).');
      Exit;
    end;

    if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;
    //conn db

    nStr := 'Select C_Card From $TB Where C_Card=''$CD'' or ' +
            'C_Card2=''$CD'' or C_Card3=''$CD''';
    nStr := MacroValue(nStr, [MI('$TB', sTable_Card), MI('$CD', nReader.FCard)]);

    with gDBConnManager.WorkerQuery(nDBConn, nStr) do
    if RecordCount > 0 then
    begin
      nCard := Fields[0].AsString;
    end else
    begin
      nStr := Format('�ſ���[ %s ]ƥ��ʧ��.', [nReader.FCard]);
      WriteHardHelperLog(nStr);
      Exit;
    end;

    try
      if nReader.FType = rtIn then
      begin
        MakeTruckIn(nCard, nReader.FID, nDBConn);
      end else

      if nReader.FType = rtOut then
      begin
        if Assigned(nReader.FOptions) then
             nStr := nReader.FOptions.Values['HYPrinter']
        else nStr := '';
        MakeTruckOut(nCard, nReader.FID, nReader.FPrinter, nStr);
      end else

      if nReader.FType = rtGate then
      begin
        if nReader.FID <> '' then
          BlueOpenDoor(nReader.FID);
        //̧��
      end else

      if nReader.FType = rtQueueGate then
      begin
        if nReader.FID <> '' then
          MakeTruckPassGate(nCard, nReader.FID, nDBConn);
        //̧��
      end;
    except
      On E:Exception do
      begin
        WriteHardHelperLog(E.Message);
      end;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBConn);
  end;
end;

//Date: 2014-10-25
//Parm: ��ͷ����
//Desc: �����ͷ�ſ�����
procedure WhenHYReaderCardArrived(const nReader: PHYReaderItem);
begin
  {$IFDEF DEBUG}
  WriteHardHelperLog(Format('�����ǩ %s:%s', [nReader.FTunnel, nReader.FCard]));
  {$ENDIF}

  if nReader.FVirtual then
  begin
    case nReader.FVType of
      rt900 :gHardwareHelper.SetReaderCard(nReader.FVReader, 'H' + nReader.FCard, False);
      rt02n :g02NReader.SetReaderCard(nReader.FVReader, 'H' + nReader.FCard);
    end;
  end else g02NReader.ActiveELabel(nReader.FTunnel, nReader.FCard);
end;

//Date: 2017/3/29
//Parm: ����һ������
//Desc: ��������һ��������Ϣ
procedure WhenTTCE_M100_ReadCard(const nItem: PM100ReaderItem);
var nStr: string;
    nRetain: Boolean;
    nCType: string;
    nDBConn: PDBWorker;
    nErrNum: Integer;
begin
  nRetain := False;
  //init

  {$IFDEF DEBUG}
  nStr := '����һ����������'  + nItem.FID + ' ::: ' + nItem.FCard;
  WriteHardHelperLog(nStr);
  {$ENDIF}

  try
    if not nItem.FVirtual then Exit;
    case nItem.FVType of
      rtOutM100 :
      begin
        nRetain := MakeTruckOut(nItem.FCard, nItem.FVReader, nItem.FVPrinter,
                                nItem.FVHYPrinter);

        if not GetCardUsed(nItem.FCard, nCType) then
          nCType := '';

        if nCType = sFlag_Provide then
        begin
          nDBConn := nil;
          with gParamManager.ActiveParam^ do
          Try
            nDBConn := gDBConnManager.GetConnection(FDB.FID, nErrNum);
            if not Assigned(nDBConn) then
            begin
              WriteHardHelperLog('����HM���ݿ�ʧ��(DBConn Is Null).');
              Exit;
            end;

            if not nDBConn.FConn.Connected then
              nDBConn.FConn.Connected := True;
            //conn db
            nStr := 'select O_CType from %s Where O_Card=''%s'' ';
            nStr := Format(nStr, [sTable_Order, nItem.FCard]);
            with gDBConnManager.WorkerQuery(nDBConn,nStr) do
            if RecordCount > 0 then
            begin
              if FieldByName('O_CType').AsString = sFlag_OrderCardG then
                nRetain := False;
            end;
          finally
            gDBConnManager.ReleaseConnection(nDBConn);
          end;
        end
        else
        if nCType = sFlag_Mul then
        begin
          nDBConn := nil;
          with gParamManager.ActiveParam^ do
          Try
            nDBConn := gDBConnManager.GetConnection(FDB.FID, nErrNum);
            if not Assigned(nDBConn) then
            begin
              WriteHardHelperLog('����HM���ݿ�ʧ��(DBConn Is Null).');
              Exit;
            end;

            if not nDBConn.FConn.Connected then
              nDBConn.FConn.Connected := True;
            //conn db
            nStr := 'select O_KeepCard from %s Where O_Card=''%s'' ';
            nStr := Format(nStr, [sTable_CardOther, nItem.FCard]);
            with gDBConnManager.WorkerQuery(nDBConn,nStr) do
            if RecordCount > 0 then
            begin
              if FieldByName('O_KeepCard').AsString = sFlag_Yes then
                nRetain := False;
            end;
          finally
            gDBConnManager.ReleaseConnection(nDBConn);
          end;
        end;
        if nRetain then
          WriteHardHelperLog('�̿���ִ��״̬:'+'������:'+nCType+'����:�̿�')
        else
          WriteHardHelperLog('�̿���ִ��״̬:'+'������:'+nCType+'����:�̿����¿�');
      end
      else gHardwareHelper.SetReaderCard(nItem.FVReader, nItem.FCard, False);
    end;
  finally
    gM100ReaderManager.DealtWithCard(nItem, nRetain)
  end;
end;

//------------------------------------------------------------------------------
procedure WriteNearReaderLog(const nEvent: string);
begin
  gSysLoger.AddLog(T02NReader, '�ֳ����������', nEvent);
end;

//Date: 2012-4-24
//Parm: ����;ͨ��;�Ƿ����Ⱥ�˳��;��ʾ��Ϣ
//Desc: ���nTuck�Ƿ������nTunnelװ��
function IsTruckInQueue(const nTruck,nTunnel: string; const nQueued: Boolean;
 var nHint: string; var nPTruck: PTruckItem; var nPLine: PLineItem;
 const nStockType: string = ''): Boolean;
var i,nIdx,nInt: Integer;
    nLineItem: PLineItem;
begin
  with gTruckQueueManager do
  try
    Result := False;
    SyncLock.Enter;
    nIdx := GetLine(nTunnel);

    if nIdx < 0 then
    begin
      nHint := Format('ͨ��[ %s ]��Ч.', [nTunnel]);
      Exit;
    end;

    nPLine := Lines[nIdx];
    nIdx := TruckInLine(nTruck, nPLine.FTrucks);

    if (nIdx < 0) and (nStockType <> '') and (
       ((nStockType = sFlag_Dai) and IsDaiQueueClosed) or
       ((nStockType = sFlag_San) and IsSanQueueClosed)) then
    begin
      for i:=Lines.Count - 1 downto 0 do
      begin
        if Lines[i] = nPLine then Continue;
        nLineItem := Lines[i];
        nInt := TruckInLine(nTruck, nLineItem.FTrucks);

        if nInt < 0 then Continue;
        //���ڵ�ǰ����
        if not StockMatch(nPLine.FStockNo, nLineItem) then Continue;
        //ˢ��������е�Ʒ�ֲ�ƥ��

        nIdx := nPLine.FTrucks.Add(nLineItem.FTrucks[nInt]);
        nLineItem.FTrucks.Delete(nInt);
        //Ų���������µ�

        nHint := 'Update %s Set T_Line=''%s'' ' +
                 'Where T_Truck=''%s'' And T_Line=''%s''';
        nHint := Format(nHint, [sTable_ZTTrucks, nPLine.FLineID, nTruck,
                nLineItem.FLineID]);
        gTruckQueueManager.AddExecuteSQL(nHint);

        nHint := '����[ %s ]��������[ %s->%s ]';
        nHint := Format(nHint, [nTruck, nLineItem.FName, nPLine.FName]);
        WriteNearReaderLog(nHint);
        Break;
      end;
    end;
    //��װ�ص�����

    if nIdx < 0 then
    begin
      nHint := Format('����[ %s ]����[ %s ]������.', [nTruck, nPLine.FName]);
      Exit;
    end;

    nPTruck := nPLine.FTrucks[nIdx];
    nPTruck.FStockName := nPLine.FName;
    //ͬ��������
    Result := True;

    if (not nQueued) or (nIdx < 1) then Exit;
    //��������,��ͷ��

    //--------------------------------------------------------------------------
    nHint := 'ͨ��[' + nPLine.FLineID + '][' + nPLine.FName +']��ǰ�Ŷӳ���˳��:';

    for i:= 0 to nPline.FTrucks.Count-1 do
    begin
      nHint := nHint + PTruckItem(nPLine.FTrucks[i]).FTruck + ',';
    end;
    WriteNearReaderLog(nHint);

    WriteNearReaderLog('��ǰˢ������:' + nPTruck.FTruck + 'ǰ��:' +
                       PTruckItem(nPLine.FTrucks[nIdx-1]).FTruck +
                       '[' + PTruckItem(nPLine.FTrucks[nIdx-1]).FBill + ']��ʼУ��:');
    nHint := '';
    if not VerifyTruckStatus(PTruckItem(nPLine.FTrucks[nIdx-1]).FBill ,
                             nPTruck.FTruck, nHint) then
    begin
      Result := False;
      Exit;
    end;

//    nInt := -1;
//    //init
//
//    for i:=nPline.FTrucks.Count-1 downto 0 do
//    if PTruckItem(nPLine.FTrucks[i]).FStarted then
//    begin
//      nInt := i;
//      Break;
//    end;
//
//    if nInt < 0 then Exit;
//    //û����װ������,�����Ŷ�
//
//    if nIdx - nInt <> 1 then
//    begin
//      nHint := '����[ %s ]��Ҫ��[ %s ]�ŶӵȺ�.';
//      nHint := Format(nHint, [nPTruck.FTruck, nPLine.FName]);
//
//      Result := False;
//      Exit;
//    end;
  finally
    SyncLock.Leave;
  end;
end;

//Date: 2013-1-21
//Parm: ͨ����;������;
//Desc: ��nTunnel�ϴ�ӡnBill��α��
function PrintBillCode(const nTunnel,nBill: string; var nHint: string): Boolean;
var nStr: string;
    nTask: Int64;
    nOut: TWorkerBusinessCommand;
begin
  Result := True;
  if not gMultiJSManager.CountEnable then Exit;

  nTask := gTaskMonitor.AddTask('UHardBusiness.PrintBillCode', cTaskTimeoutLong);
  //to mon
  
  if not CallHardwareCommand(cBC_PrintCode, nBill, nTunnel, @nOut) then
  begin
    nStr := '��ͨ��[ %s ]���ͷ�Υ����ʧ��,����: %s';
    nStr := Format(nStr, [nTunnel, nOut.FData]);  
    WriteNearReaderLog(nStr);
  end;

  gTaskMonitor.DelTask(nTask, True);
  //task done
end;

//Date: 2012-4-24
//Parm: ����;ͨ��;������;��������
//Desc: ����nTunnel�ĳ�������������
function TruckStartJS(const nTruck,nTunnel,nBill: string;
  var nHint: string; const nAddJS: Boolean = True): Boolean;
var nIdx: Integer;
    nTask: Int64;
    nPLine: PLineItem;
    nPTruck: PTruckItem;
begin
  with gTruckQueueManager do
  try
    Result := False;
    SyncLock.Enter;
    nIdx := GetLine(nTunnel);

    if nIdx < 0 then
    begin
      nHint := Format('ͨ��[ %s ]��Ч.', [nTunnel]);
      Exit;
    end;

    nPLine := Lines[nIdx];
    nIdx := TruckInLine(nTruck, nPLine.FTrucks);

    if nIdx < 0 then
    begin
      nHint := Format('����[ %s ]�Ѳ��ٶ���.', [nTruck]);
      Exit;
    end;

    Result := True;
    nPTruck := nPLine.FTrucks[nIdx];

    for nIdx:=nPLine.FTrucks.Count - 1 downto 0 do
      PTruckItem(nPLine.FTrucks[nIdx]).FStarted := False;
    nPTruck.FStarted := True;

    if PrintBillCode(nTunnel, nBill, nHint) and nAddJS then
    begin
      nTask := gTaskMonitor.AddTask('UHardBusiness.AddJS', cTaskTimeoutLong);
      //to mon
      
      gMultiJSManager.AddJS(nTunnel, nTruck, nBill, nPTruck.FDai, True);
      gTaskMonitor.DelTask(nTask);
    end;
  finally
    SyncLock.Leave;
  end;
end;

//Date: 2013-07-17
//Parm: ��������
//Desc: ��ѯnBill�ϵ���װ��
function GetHasDai(const nBill: string): Integer;
var nStr: string;
    nIdx: Integer;
    nDBConn: PDBWorker;
begin
  if not gMultiJSManager.ChainEnable then
  begin
    Result := 0;
    Exit;
  end;

  Result := gMultiJSManager.GetJSDai(nBill);
  if Result > 0 then Exit;

  nDBConn := nil;
  with gParamManager.ActiveParam^ do
  try
    nDBConn := gDBConnManager.GetConnection(FDB.FID, nIdx);
    if not Assigned(nDBConn) then
    begin
      WriteNearReaderLog('����HM���ݿ�ʧ��(DBConn Is Null).');
      Exit;
    end;

    if not nDBConn.FConn.Connected then
      nDBConn.FConn.Connected := True;
    //conn db

    nStr := 'Select T_Total From %s Where T_Bill=''%s''';
    nStr := Format(nStr, [sTable_ZTTrucks, nBill]);

    with gDBConnManager.WorkerQuery(nDBConn, nStr) do
    if RecordCount > 0 then
    begin
      Result := Fields[0].AsInteger;
    end;
  finally
    gDBConnManager.ReleaseConnection(nDBConn);
  end;
end;

//Date: 2017-10-16
//Parm: ����;���ڵ�;��λ
//Desc: ����װ������
procedure MakeLadingSound(const nTruck: PTruckItem; const nLine: PLineItem;
  const nPost: string);
var nStr: string;
    nIdx: Integer;
    nNext: PTruckItem;
begin
  try
    nIdx := nLine.FTrucks.IndexOf(nTruck);

    if nIdx = nLine.FTrucks.Count - 1 then
    begin
      nStr := '����[p500]%s��ʼװ��';
      nStr := Format(nStr, [nTruck.FTruck]);

      nStr := nStr + ',' + gTruckQueueManager.IsSafeVocie;

      {$IFNDEF NoUsePlayVoice}
      gNetVoiceHelper.PlayVoice(nStr, nPost);
      {$ENDIF}

      WriteNearReaderLog(nStr);
      //log content
    end;
    if (nIdx < 0) or (nIdx = nLine.FTrucks.Count - 1) then Exit;
    //no exits or last

    nNext := nLine.FTrucks[nIdx+1];
    //next truck

    nStr := '����[p500]%s��ʼװ��,��%s׼��';
    nStr := Format(nStr, [nTruck.FTruck, nNext.FTruck]);

    nStr := nStr + ',' + gTruckQueueManager.IsSafeVocie;
    {$IFNDEF NoUsePlayVoice}
    gNetVoiceHelper.PlayVoice(nStr, nPost);
    {$ENDIF}

    WriteNearReaderLog(nStr);
    //log content
  except
    on nErr: Exception do
    begin
      nStr := '����[ %s ]����ʧ��,����: %s';
      nStr := Format(nStr, [nPost, nErr.Message]);
      WriteNearReaderLog(nStr);
    end;
  end;
end;

//Date: 2012-4-24
//Parm: �ſ���;ͨ����
//Desc: ��nCardִ�д�װװ������
procedure MakeTruckLadingDai(const nCard: string; nTunnel: string);
var nStr: string;
    nIdx,nInt: Integer;
    nPLine: PLineItem;
    nPTruck: PTruckItem;
    nTrucks: TLadingBillItems;
    nBool: Boolean;

    function IsJSRun: Boolean;
    begin
      Result := False;
      if nTunnel = '' then Exit;
      Result := gMultiJSManager.IsJSRun(nTunnel);

      if Result then
      begin
        nStr := 'ͨ��[ %s ]װ����,ҵ����Ч.';
        nStr := Format(nStr, [nTunnel]);
        WriteNearReaderLog(nStr);
      end;
    end;
begin
  WriteNearReaderLog('ͨ��[ ' + nTunnel + ' ]: MakeTruckLadingDai����.');

  if IsJSRun then Exit;
  //tunnel is busy

  if not GetLadingBills(nCard, sFlag_TruckZT, nTrucks) then
  begin
    nStr := '��ȡ�ſ�[ %s ]��������Ϣʧ��.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '�ſ�[ %s ]û����Ҫջ̨�������.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  if nTunnel = '' then
  begin
    nTunnel := gTruckQueueManager.GetTruckTunnel(nTrucks[0].FTruck);
    //���¶�λ�������ڳ���
    if IsJSRun then Exit;
  end;

  if gTruckQueueManager.IsDaiForceQueue then
  begin
    nBool := True;
    for nIdx:=Low(nTrucks) to High(nTrucks) do
    begin
      nBool := nTrucks[nIdx].FNextStatus = sFlag_TruckZT;
      //δװ��,����Ŷ�˳��
      if not nBool then Break;
    end;
  end
  else
    nBool := False;
  
  if not IsTruckInQueue(nTrucks[0].FTruck, nTunnel, nBool, nStr,
         nPTruck, nPLine, sFlag_Dai) then
  begin
    WriteNearReaderLog(nStr);
    if nBool and (Pos('�Ⱥ�', nStr) > 0) then
      nStr := nTrucks[0].FTruck + '���ŶӵȺ�'
    else
      nStr := nTrucks[0].FTruck + '�뻻��װ��';
    nStr := nStr + ',' + gTruckQueueManager.IsSafeVocie;
    {$IFNDEF NoUsePlayVoice}
    gNetVoiceHelper.PlayVoice(nStr, sPost_ZT);
    {$ENDIF}
    Exit;
  end; //���ͨ��

  nStr := '';
  nInt := 0;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if (FStatus = sFlag_TruckZT) or (FNextStatus = sFlag_TruckZT) then
    begin
      FSelected := Pos(FID, nPTruck.FHKBills) > 0;
      if FSelected then Inc(nInt); //ˢ��ͨ����Ӧ�Ľ�����
      Continue;
    end;

    FSelected := False;
    nStr := '����[ %s ]��һ״̬Ϊ:[ %s ],�޷�ջ̨���.';
    nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);
  end;

  if nInt < 1 then
  begin
    WriteHardHelperLog(nStr);
    Exit;
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    if not FSelected then Continue;
    if FStatus <> sFlag_TruckZT then Continue;

    nStr := '��װ����[ %s ]�ٴ�ˢ��װ��.';
    nStr := Format(nStr, [nPTruck.FTruck]);
    WriteNearReaderLog(nStr);

    MakeLadingSound(nPTruck, nPLine, sPost_ZT);
    //��������

    if not TruckStartJS(nPTruck.FTruck, nTunnel, nPTruck.FBill, nStr,
       GetHasDai(nPTruck.FBill) < 1) then
      WriteNearReaderLog(nStr);
    Exit;
  end;

  if not SaveLadingBills(sFlag_TruckZT, nTrucks) then
  begin
    nStr := '����[ %s ]ջ̨���ʧ��.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  MakeLadingSound(nPTruck, nPLine, sPost_ZT);
  //��������

  if not TruckStartJS(nPTruck.FTruck, nTunnel, nPTruck.FBill, nStr) then
    WriteNearReaderLog(nStr);
  Exit;
end;

//Date: 2012-4-25
//Parm: ����;ͨ��
//Desc: ��ȨnTruck��nTunnel�����Ż�
procedure TruckStartFH(const nTruck: PTruckItem; const nTunnel, IsLBC: string);
var nStr,nTmp,nCardUse: string;
   nField: TField;
   nWorker: PDBWorker;
   i : Integer;
begin
  nWorker := nil;
  try
    nTmp := '';
    nStr := 'Select * From %s Where T_Truck=''%s''';
    nStr := Format(nStr, [sTable_Truck, nTruck.FTruck]);

    with gDBConnManager.SQLQuery(nStr, nWorker) do
    if RecordCount > 0 then
    begin
      nField := FindField('T_Card');
      if Assigned(nField) then nTmp := nField.AsString;

      nField := FindField('T_CardUse');
      if Assigned(nField) then nCardUse := nField.AsString;

      if nCardUse = sFlag_No then
        nTmp := '';
      //xxxxx
    end;

    g02NReader.SetRealELabel(nTunnel, nTmp);
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;
  
  gERelayManager.LineOpen(nTunnel);
  //�򿪷Ż�
  nStr := nTruck.FTruck + StringOfChar(' ', 12 - Length(nTruck.FTruck));
  nTmp := nTruck.FStockName + FloatToStr(nTruck.FValue);
  nStr := nStr + nTruck.FStockName + StringOfChar(' ', 12 - Length(nTmp)) +
          FloatToStr(nTruck.FValue);
  //xxxxx
  WriteHardHelperLog('С��' + ntunnel + '����:' + nStr);
  for i := 0 to 2 do
  begin
    gERelayManager.ShowTxt(nTunnel, nStr);
  end;
  //��ʾ����
  WriteHardHelperLog('�Ƿ������' + IsLBC);
  if IsLBC = 'Y' then
  begin
    {$IFDEF UseLBCModbus}
    gModBusClient.StartWeight(nTunnel, nTruck.FBill, nTruck.FValue);
    //��ʼ����װ��
    {$ENDIF}
  end;
end;

//Date: 2012-4-24
//Parm: �ſ���;ͨ����
//Desc: ��nCardִ�д�װװ������
procedure MakeTruckLadingSan(const nCard,nTunnel,IsLBC,IsZZC: string);
var nStr: string;
    nIdx: Integer;
    nPLine: PLineItem;
    nPTruck: PTruckItem;
    nTrucks: TLadingBillItems;
    nBool: Boolean;
begin
  {$IFDEF DEBUG}
  WriteNearReaderLog('MakeTruckLadingSan����.');
  {$ENDIF}

  if not GetLadingBills(nCard, sFlag_TruckFH, nTrucks) then
  begin
    nStr := '��ȡ�ſ�[ %s ]��������Ϣʧ��.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  if Length(nTrucks) < 1 then
  begin
    nStr := '�ſ�[ %s ]û����Ҫ�Żҳ���.';
    nStr := Format(nStr, [nCard]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  for nIdx:=Low(nTrucks) to High(nTrucks) do
  with nTrucks[nIdx] do
  begin
    {$IFDEF AllowMultiM}
    if FStatus = sFlag_TRuckBFM then
    begin
      FStatus := sFlag_TruckFH;
    end;
    //���غ�������(״̬��������Ƥ��,��ֹ�������)
    {$ENDIF}
    
    if (FStatus = sFlag_TruckFH) or (FNextStatus = sFlag_TruckFH) then Continue;
    //δװ����װ

    nStr := '����[ %s ]��һ״̬Ϊ:[ %s ],�޷��Ż�.';
    nStr := Format(nStr, [FTruck, TruckStatusToStr(FNextStatus)]);
    //С����ʾ
    gERelayManager.ShowTxt(nTunnel, nStr);

    WriteHardHelperLog(nStr);
    Exit;
  end;

  if gTruckQueueManager.IsSanForceQueue then
  begin
    nBool := True;
    for nIdx:=Low(nTrucks) to High(nTrucks) do
    begin
      nBool := nTrucks[nIdx].FNextStatus = sFlag_TruckFH;
      //δװ��,����Ŷ�˳��
      if not nBool then Break;
    end;
  end
  else
    nBool := False;

  if not IsTruckInQueue(nTrucks[0].FTruck, nTunnel, nBool, nStr,
         nPTruck, nPLine, sFlag_San) then
  begin 
    WriteNearReaderLog(nStr);
    //loged

    nIdx := Length(nTrucks[0].FTruck);
    if nBool and (Pos('�Ⱥ�', nStr) > 0) then
      nStr := nTrucks[0].FTruck + StringOfChar(' ',12 - nIdx) + '���ŶӵȺ�'
    else
      nStr := nTrucks[0].FTruck + StringOfChar(' ',12 - nIdx) + '�뻻��װ��';
    gERelayManager.ShowTxt(nTunnel, nStr);

    if nBool and (Pos('�Ⱥ�', nStr) > 0) then
      nStr := nTrucks[0].FTruck + '���ŶӵȺ�'
    else
      nStr := nTrucks[0].FTruck + '�뻻��װ��';
    nStr := nStr + ',' + gTruckQueueManager.IsSafeVocie;
    {$IFNDEF NoUsePlayVoice}
    gNetVoiceHelper.PlayVoice(nStr, sPost_FH);
    {$ENDIF}
    Exit;
  end; //���ͨ��

  if nTrucks[0].FStatus = sFlag_TruckFH then
  begin
    nStr := 'ɢװ����[ %s ]�ٴ�ˢ��װ��.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);
    WriteNearReaderLog(nStr);

    MakeLadingSound(nPTruck, nPLine, sPost_FH);
    //��������

    TruckStartFH(nPTruck, nTunnel, IsLBC);

    {$IFDEF FixLoad}
    if IsZZC = 'Y' then
    begin
      WriteNearReaderLog('��������װ��::'+nTunnel+'@'+nCard);
      //���Ϳ��ź�ͨ���ŵ�����װ��������
      gSendCardNo.SendCardNo(nTunnel+'@'+nCard);
    end;
    {$ENDIF}
    
    Exit;
  end;

  if not SaveLadingBills(sFlag_TruckFH, nTrucks) then
  begin
    nStr := '����[ %s ]�ŻҴ����ʧ��.';
    nStr := Format(nStr, [nTrucks[0].FTruck]);

    WriteNearReaderLog(nStr);
    Exit;
  end;

  MakeLadingSound(nPTruck, nPLine, sPost_FH);
  //��������

  TruckStartFH(nPTruck, nTunnel, IsLBC);
  //ִ�зŻ�

  {$IFDEF FixLoad}
  if IsZZC = 'Y' then
  begin
    WriteNearReaderLog('��������װ��::'+nTunnel+'@'+nCard);
    //���Ϳ��ź�ͨ���ŵ�����װ��������
    gSendCardNo.SendCardNo(nTunnel+'@'+nCard);
  end;
  {$ENDIF}
end;

//Date: 2012-4-24
//Parm: ����;����
//Desc: ��nHost.nCard�µ�������������
procedure WhenReaderCardIn(const nCard: string; const nHost: PReaderHost);
var nStr: string;
    nIsLBC,nIsZZC:string;
begin 
  if nHost.FType = rtOnce then
  begin
    if nHost.FFun = rfOut then
    begin
      if Assigned(nHost.FOptions) then
           nStr := nHost.FOptions.Values['HYPrinter']
      else nStr := '';
      MakeTruckOut(nCard, '', nHost.FPrinter, nStr);
    end else MakeTruckLadingDai(nCard, nHost.FTunnel);
  end else

  if nHost.FType = rtKeep then
  begin
    if Assigned(nHost.FOptions) then
         nIsLBC := nHost.FOptions.Values['IsLBC']
    else nIsLBC := 'N';

    if Assigned(nHost.FOptions) then
         nIsZZC := nHost.FOptions.Values['IsZZC']
    else nIsZZC := 'N';

    MakeTruckLadingSan(nCard, nHost.FTunnel, nIsLBC, nIsZZC);
  end;
end;

//Date: 2012-4-24
//Parm: ����;����
//Desc: ��nHost.nCard��ʱ����������
procedure WhenReaderCardOut(const nCard: string; const nHost: PReaderHost);
var
  nIsLBC,nIsZZC : string;
begin
  {$IFDEF DEBUG}
  WriteHardHelperLog('WhenReaderCardOut�˳�.');
  {$ENDIF}

  gERelayManager.LineClose(nHost.FTunnel);
  Sleep(100);

  {$IFDEF UseLBCModbus}
  if Assigned(nHost.FOptions) then
       nIsLBC := nHost.FOptions.Values['IsLBC']
  else nIsLBC := 'N';
  if nIsLBC = 'Y' then
  begin
    gModBusClient.StopWeightSaveNum(nHost.FTunnel);
  end;
  {$ENDIF}

  {$IFDEF FixLoad}
  if Assigned(nHost.FOptions) then
       nIsZZC := nHost.FOptions.Values['IsZZC']
  else nIsZZC := 'N';
  if nIsZZC = 'Y' then
  begin
    WriteHardHelperLog('ֹͣ����װ��::'+nHost.FTunnel+'@Close');
    //���Ϳ��ź�ͨ���ŵ�����װ��������
    gSendCardNo.SendCardNo(nHost.FTunnel+'@Close');
  end;
  {$ENDIF}

  if nHost.FETimeOut then
       gERelayManager.ShowTxt(nHost.FTunnel, '���ӱ�ǩ������Χ')
  else gERelayManager.ShowTxt(nHost.FTunnel, nHost.FLEDText);
  Sleep(100);
end;

//------------------------------------------------------------------------------
//Date: 2012-12-16
//Parm: �ſ���
//Desc: ��nCardNo���Զ�����(ģ���ͷˢ��)
procedure MakeTruckAutoOut(const nCardNo: string);
var nReader: string;
begin
  if gTruckQueueManager.IsTruckAutoOut then
  begin
    nReader := gHardwareHelper.GetReaderLastOn(nCardNo);
    if nReader <> '' then
      gHardwareHelper.SetReaderCard(nReader, nCardNo);
    //ģ��ˢ��
  end;
end;

//Date: 2012-12-16
//Parm: ��������
//Desc: ����ҵ���м����Ӳ���ػ��Ľ�������
procedure WhenBusinessMITSharedDataIn(const nData: string);
begin
  WriteHardHelperLog('�յ�Bus_MITҵ������:::' + nData);
  //log data

  if Pos('TruckOut', nData) = 1 then
    MakeTruckAutoOut(Copy(nData, Pos(':', nData) + 1, MaxInt));
  //auto out
end;

//Date: 2015-01-14
//Parm: ���ƺ�;������
//Desc: ��ʽ��nBill��������Ҫ��ʾ�ĳ��ƺ�
function GetJSTruck(const nTruck,nBill: string): string;
var nStr: string;
    nLen: Integer;
    nWorker: PDBWorker;
begin
  Result := nTruck;
  if nBill = '' then Exit;

  {$IFDEF LNYK}
  nWorker := nil;
  try
    nStr := 'Select L_StockNo From %s Where L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, nBill]);

    with gDBConnManager.SQLQuery(nStr, nWorker) do
    if RecordCount > 0 then
    begin
      nStr := UpperCase(Fields[0].AsString);
      if nStr <> 'BPC-02' then Exit;
      //ֻ����32.5(b)

      nLen := cMultiJS_Truck - 2;
      Result := 'B-' + Copy(nTruck, Length(nTruck) - nLen + 1, nLen);
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;
  {$ENDIF}

  {$IFDEF JSTruck}
  nWorker := nil;
  try
    nStr := 'Select D_ParamC From %s b' +
            ' Left Join %s d On d.D_Name=''%s'' and d.D_Value=b.L_StockName ' +
            'Where b.L_ID=''%s''';
    nStr := Format(nStr, [sTable_Bill, sTable_SysDict, sFlag_StockItem, nBill]);

    with gDBConnManager.SQLQuery(nStr, nWorker) do
    if RecordCount > 0 then
    begin
      nStr := Trim(Fields[0].AsString);
      if nStr = '' then Exit;
      //common,��ͨ�������ʽ��

      Result := Copy(Fields[0].AsString + '-', 1, 2) +
                Copy(Result, 3, cMultiJS_Truck - 2);
      //format
      nStr := '���������ƺŸ�ʽ��ǰ:[ %s ],��ʽ����:[ %s ].';
      nStr := Format(nStr, [nTruck,Result]);

      WriteHardHelperLog(nStr, sPost_In);
    end;
  finally
    gDBConnManager.ReleaseConnection(nWorker);
  end;
  {$ENDIF}
end;

//Date: 2013-07-17
//Parm: ������ͨ��
//Desc: ����nTunnel�������
procedure WhenSaveJS(const nTunnel: PMultiJSTunnel);
var nStr: string;
    nDai: Word;
    nList: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  nDai := nTunnel.FHasDone - nTunnel.FLastSaveDai;
  if nDai <= 0 then Exit;
  //invalid dai num

  if nTunnel.FLastBill = '' then Exit;
  //invalid bill

  nList := nil;
  try
    nList := TStringList.Create;
    nList.Values['Bill'] := nTunnel.FLastBill;
    nList.Values['Dai'] := IntToStr(nDai);

    nStr := PackerEncodeStr(nList.Text);
    CallHardwareCommand(cBC_SaveCountData, nStr, '', @nOut)
  finally
    nList.Free;
  end;
end;

function VerifySnapTruck(const nTruck,nBill,nPos: string; var nResult: string): Boolean;
var nList: TStrings;
    nOut: TWorkerBusinessCommand;
begin
  nList := nil;
  try
    nList := TStringList.Create;
    nList.Values['Truck'] := nTruck;
    nList.Values['Bill'] := nBill;
    nList.Values['Pos'] := nPos;

    Result := CallBusinessCommand(cBC_VerifySnapTruck, nList.Text, '', @nOut);
    nResult := nOut.FData;
  finally
    nList.Free;
  end;
end;

{$IFDEF UseLBCModbus}
procedure WhenLBCWeightStatusChange(const nTunnel: PLBTunnel);
var
  nStr, nTruck, nMsg: string;
  nList : TStrings;
  nIdx  : Integer;
begin
  if nTunnel.FStatusNew = bsDone then
  begin
    gERelayManager.ShowTxt(nTunnel.FID, 'װ����� ���°�');

    gERelayManager.LineClose(nTunnel.FID);
    Sleep(100);
    WriteNearReaderLog('�������:' + nTunnel.FID + '���ݺţ�' + nTunnel.FBill);
    Exit;
  end;
  
  if nTunnel.FStatusNew = bsProcess then
  begin
    if nTunnel.FWeightMax > 0 then
    begin
      nStr := Format('%.2f/%.2f', [nTunnel.FWeightMax, nTunnel.FValTunnel]);
    end
    else nStr := Format('%.2f/%.2f', [nTunnel.FValue, nTunnel.FValTunnel]);
    
    gERelayManager.ShowTxt(nTunnel.FID, nStr);
    Exit;
  end;

  case nTunnel.FStatusNew of
   bsInit      : WriteNearReaderLog('��ʼ��:' + nTunnel.FID   + '���ݺţ�' + nTunnel.FBill);
   bsNew       : WriteNearReaderLog('�����:' + nTunnel.FID   + '���ݺţ�' + nTunnel.FBill);
   bsStart     : WriteNearReaderLog('��ʼ����:' + nTunnel.FID + '���ݺţ�' + nTunnel.FBill);
   bsClose     : WriteNearReaderLog('���عر�:' + nTunnel.FID + '���ݺţ�' + nTunnel.FBill);
  end; //log

  if nTunnel.FStatusNew = bsClose then
  begin
    gERelayManager.ShowTxt(nTunnel.FID, 'װ��ҵ��ر�');
    WriteNearReaderLog(nTunnel.FID+'װ��ҵ��ر�');
    Exit;
  end;
end;
{$ENDIF}

end.
