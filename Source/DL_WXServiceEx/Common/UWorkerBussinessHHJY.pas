{*******************************************************************************
  ����: juner11212436@163.com 2018-10-25
  ����: ��Ӿ�Զ���ҵ������ݴ���
*******************************************************************************}
unit UWorkerBussinessHHJY;

{$I Link.Inc}
interface

uses
  Windows, Classes, Controls, SysUtils, DB, ADODB, NativeXml, UBusinessWorker,
  UBusinessPacker, UBusinessConst, UMgrDBConn, UMgrParam, UFormCtrl, USysLoger,
  ZnMD5, ULibFun, USysDB, UMITConst, UMgrChannel,IdHTTP,Graphics,
  Variants, uSuperObject, MsMultiPartFormData, uLkJSON, DateUtils;

const
  cHttpTimeOut          = 10;
  
type
  TMITDBWorker = class(TBusinessWorkerBase)
  protected
    FErrNum: Integer;
    //������
    FDBConn: PDBWorker;
    //����ͨ��
    FDataIn,FDataOut: PBWDataBase;
    //��γ���
    FDataOutNeedUnPack: Boolean;
    //��Ҫ���
    FPackOut: Boolean;
    procedure GetInOutData(var nIn,nOut: PBWDataBase); virtual; abstract;
    //�������
    function VerifyParamIn(var nData: string): Boolean; virtual;
    //��֤���
    function DoDBWork(var nData: string): Boolean; virtual; abstract;
    function DoAfterDBWork(var nData: string; nResult: Boolean): Boolean; virtual;
    //����ҵ��
  public
    function DoWork(var nData: string): Boolean; override;
    //ִ��ҵ��
    procedure WriteLog(const nEvent: string);
    //��¼��־
  end;

  TBusWorkerBusinessHHJY = class(TMITDBWorker)
  private
    FListA,FListB,FListC,FListD,FListE: TStrings;
    //list
    FIn: TWorkerHHJYData;
    FOut: TWorkerHHJYData;
    //in out
    FIdHttp : TIdHTTP;
    FUrl    : string;
    Ftoken  : string;
  protected
    procedure GetInOutData(var nIn,nOut: PBWDataBase); override;
    function DoDBWork(var nData: string): Boolean; override;

    function UnicodeToChinese(inputstr: string): string;
    function GetLoginToken(var nData: string): Boolean;
    function GetOrderInfoEx(var nData: string): Boolean;
    function GetSaleInfo(var nData: string): Boolean;
  public
    constructor Create; override;
    destructor destroy; override;
    //new free
    function GetFlagStr(const nFlag: Integer): string; override;
    class function FunctionName: string; override;
    //base function
    class function CallMe(const nCmd: Integer; const nData,nExt: string;
      const nOut: PWorkerBusinessCommand): Boolean;
    //local call
  end;

implementation

//Date: 2012-3-13
//Parm: ���������
//Desc: ��ȡ�������ݿ��������Դ
function TMITDBWorker.DoWork(var nData: string): Boolean;
begin
  Result := False;
  FDBConn := nil;

  with gParamManager.ActiveParam^ do
  try
    FDBConn := gDBConnManager.GetConnection(FDB.FID, FErrNum);
    if not Assigned(FDBConn) then
    begin
      nData := '�������ݿ�ʧ��(DBConn Is Null).';
      Exit;
    end;

    if not FDBConn.FConn.Connected then
      FDBConn.FConn.Connected := True;
    //conn db

    FDataOutNeedUnPack := True;
    GetInOutData(FDataIn, FDataOut);
    FPacker.UnPackIn(nData, FDataIn);

    with FDataIn.FVia do
    begin
      FUser   := gSysParam.FAppFlag;
      FIP     := gSysParam.FLocalIP;
      FMAC    := gSysParam.FLocalMAC;
      FTime   := FWorkTime;
      FKpLong := FWorkTimeInit;
    end;

    {$IFDEF DEBUG}
    WriteLog('Fun: '+FunctionName+' InData:'+ FPacker.PackIn(FDataIn, False));
    {$ENDIF}
    if not VerifyParamIn(nData) then Exit;
    //invalid input parameter

    FPacker.InitData(FDataOut, False, True, False);
    //init exclude base
    FDataOut^ := FDataIn^;

    Result := DoDBWork(nData);
    //execute worker

    if Result then
    begin
      if FDataOutNeedUnPack then
        FPacker.UnPackOut(nData, FDataOut);
      //xxxxx

      Result := DoAfterDBWork(nData, True);
      if not Result then Exit;

      with FDataOut.FVia do
        FKpLong := GetTickCount - FWorkTimeInit;
      if FPackOut then
      begin
        WriteLog('���');
        nData := FPacker.PackOut(FDataOut);
      end;

      {$IFDEF DEBUG}
      WriteLog('Fun: '+FunctionName+' OutData:'+ FPacker.PackOut(FDataOut, False));
      {$ENDIF}
    end else DoAfterDBWork(nData, False);
  finally
    gDBConnManager.ReleaseConnection(FDBConn);
  end;
end;

//Date: 2012-3-22
//Parm: �������;���
//Desc: ����ҵ��ִ����Ϻ����β����
function TMITDBWorker.DoAfterDBWork(var nData: string; nResult: Boolean): Boolean;
begin
  Result := True;
end;

//Date: 2012-3-18
//Parm: �������
//Desc: ��֤��������Ƿ���Ч
function TMITDBWorker.VerifyParamIn(var nData: string): Boolean;
begin
  Result := True;
end;

//Desc: ��¼nEvent��־
procedure TMITDBWorker.WriteLog(const nEvent: string);
begin
  gSysLoger.AddLog(TMITDBWorker, FunctionName, nEvent);
end;

//------------------------------------------------------------------------------
class function TBusWorkerBusinessHHJY.FunctionName: string;
begin
  Result := sBus_BusinessHHJY;
end;

constructor TBusWorkerBusinessHHJY.Create;
begin
  FListA := TStringList.Create;
  FListB := TStringList.Create;
  FListC := TStringList.Create;
  FListD := TStringList.Create;
  FListE := TStringList.Create;
  FidHttp := TIdHTTP.Create(nil);
  FidHttp.ConnectTimeout := cHttpTimeOut * 1000;
  FidHttp.ReadTimeout := cHttpTimeOut * 1000;
  inherited;
end;

destructor TBusWorkerBusinessHHJY.destroy;
begin
  FreeAndNil(FListA);
  FreeAndNil(FListB);
  FreeAndNil(FListC);
  FreeAndNil(FListD);
  FreeAndNil(FListE);
  FreeAndNil(FidHttp);
  inherited;
end;

function TBusWorkerBusinessHHJY.GetFlagStr(const nFlag: Integer): string;
begin
  Result := inherited GetFlagStr(nFlag);

  case nFlag of
   cWorker_GetPackerName : Result := sBus_BusinessHHJY;
  end;
end;

procedure TBusWorkerBusinessHHJY.GetInOutData(var nIn,nOut: PBWDataBase);
begin
  nIn := @FIn;
  nOut := @FOut;
  FDataOutNeedUnPack := False;
end;

//Date: 2014-09-15
//Parm: ����;����;����;���
//Desc: ���ص���ҵ�����
class function TBusWorkerBusinessHHJY.CallMe(const nCmd: Integer;
  const nData, nExt: string; const nOut: PWorkerBusinessCommand): Boolean;
var nStr: string;
    nIn: TWorkerHHJYData;
    nPacker: TBusinessPackerBase;
    nWorker: TBusinessWorkerBase;
begin
  nPacker := nil;
  nWorker := nil;
  try
    nIn.FCommand := nCmd;
    nIn.FData := nData;
    nIn.FExtParam := nExt;

    nPacker := gBusinessPackerManager.LockPacker(sBus_BusinessHHJY);
    nPacker.InitData(@nIn, True, False);
    //init

    nStr := nPacker.PackIn(@nIn);
    nWorker := gBusinessWorkerManager.LockWorker(sBus_BusinessHHJY);
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

//Date: 2012-3-22
//Parm: ��������
//Desc: ִ��nDataҵ��ָ��
function TBusWorkerBusinessHHJY.DoDBWork(var nData: string): Boolean;
begin
  with FOut.FBase do
  begin
    FResult := True;
    FErrCode := 'S.00';
    FErrDesc := 'ҵ��ִ�гɹ�.';
  end;
  FPackOut := True;

  case FIn.FCommand of
    cBC_GetLoginToken        : Result := GetLoginToken(nData);
    cBC_GetOrderInfoEx       : Result := GetOrderInfoEx(nData);
    cBC_GetSaleInfo          : Result := GetSaleInfo(nData);    
  else
    begin
      Result := False;
      nData := '��Ч��ҵ�����(Code: %d Invalid Command).';
      nData := Format(nData, [FIn.FCommand]);
    end;
  end;
end;

function TBusWorkerBusinessHHJY.GetOrderInfoEx(var nData: string): Boolean;
var nStr, nProStr, nMatStr, nYearStr, nSQL : string;
    nHasDone: Double;
    nYearMonth,szUrl : string;
    ReJo, OneJo : ISuperObject;
    ArrsJa,ArrsJaSub: TSuperArray;
    wParam: TStrings;
    ReStream:TStringstream;
    nIdx: Integer;
    nO_Valid: string;
    nYear, nMonth, nDays : Word;
    nDataStream: TMsMultiPartFormDataStream;
begin
  Result := False;

  FListA.Clear;
  FListB.Clear;
  FListC.Clear;
  FListD.Clear;
  FListE.Clear;
  Result      := True;
  wParam      := TStringList.Create;
  ReStream    := TStringstream.Create('');
  nDataStream := TMsMultiPartFormDataStream.Create;

  FListA.Text := PackerDecodeStr(FIn.FData);
  try
    wParam.Clear;
    wParam.Values['token']     := Ftoken;

    if FListA.Values['YearPeriod'] <> '' then
    begin
      nYearMonth := FListA.Values['YearPeriod'];
      nYear      := StrToInt(Copy(nYearMonth,1,Pos('-',nYearMonth)-1));
      nMonth     := StrToInt(Copy(nYearMonth,Pos('-',nYearMonth)+1,MaxInt));
      nDays      := DaysInAMonth(nYear,nMonth);
      wParam.Values['starttime'] := FListA.Values['YearPeriod']+'-01 00:00:00';
      wParam.Values['endtime']   := FListA.Values['YearPeriod']+'-'+inttostr(nDays)+' 23:59:59';
    end
    else
    begin
      wParam.Values['starttime'] := DateTime2Str(IncMonth(Now,-1));
      wParam.Values['endtime']   := DateTime2Str(Now);
    end;
    if FListA.Values['Materiel'] <> '' then
      wParam.Values['product_name'] := FListA.Values['Materiel'];
    if FListA.Values['Provider'] <> '' then
      wParam.Values['partner_name'] := FListA.Values['Provider'];

    nStr := 'token:'+Ftoken;
    WriteLog('��ѯ�ɹ�������Σ�' + nStr);

    nDataStream.AddFormField('token', Ftoken);
    if FListA.Values['YearPeriod'] <> '' then
    begin
      nYearMonth := FListA.Values['YearPeriod'];
      nYear      := StrToInt(Copy(nYearMonth,1,Pos('-',nYearMonth)-1));
      nMonth     := StrToInt(Copy(nYearMonth,Pos('-',nYearMonth)+1,MaxInt));
      nDays      := DaysInAMonth(nYear,nMonth);
      nDataStream.AddFormField('starttime', FListA.Values['YearPeriod']+'-01 00:00:00');
      if (FListA.Values['Materiel'] = '') and (FListA.Values['Provider'] = '') then
        nDataStream.AddFormField('endtime', FListA.Values['YearPeriod']+'-'+inttostr(nDays)+' 23:59:59'+ CRLF)
      else
        nDataStream.AddFormField('endtime', FListA.Values['YearPeriod']+'-'+inttostr(nDays)+' 23:59:59');
    end
    else
    begin
      nDataStream.AddFormField('starttime', DateTime2Str(IncMonth(Now,-1)));
      if (FListA.Values['Materiel'] = '') and (FListA.Values['Provider'] = '') then
        nDataStream.AddFormField('endtime', DateTime2Str(Now)+ CRLF)
      else
        nDataStream.AddFormField('endtime', DateTime2Str(Now));
    end;

    if FListA.Values['Materiel'] <> '' then
    begin
      nDataStream.AddFormField('product_name', FListA.Values['Materiel']);
    end;
    if FListA.Values['Provider'] <> '' then
    begin
      nDataStream.AddFormField('partner_name', FListA.Values['Provider']);
    end;
    nDataStream.done;

    szUrl := gSysParam.FWXERPUrl + '/purchaseorder';
    FIdHttp.HTTPOptions:=FIdHttp.HTTPOptions+[hoKeepOrigProtocol];
    FidHttp.ProtocolVersion:= pv1_1;
    FidHttp.Request.ContentType := nDataStream.RequestContentType;
    FidHttp.Post(szUrl, nDataStream, ReStream);
    nStr := ReStream.DataString;
    nStr := UTF8Decode(ReStream.DataString);
    nStr := UnicodeToChinese(nStr);


    WriteLog('�ɹ��������Σ�' + nStr);
    FListA.Clear;
    FListB.Clear;
    if nStr <> '' then
    begin
      ReJo    := SO(nStr);
      ReJo    := SO(ReJo.S['Response']);
      ArrsJa  := ReJo.A['Infos'];
      if ArrsJa <> nil then
      begin
        if ArrsJa.Length = 0 then
        begin
          WriteLog('���ڼ��޲ɹ�����');
          Result     := True;
          FOut.FData :='';
          FOut.FBase.FResult := True;
        end
        else
        begin
          for nIdx := 0 to ArrsJa.Length - 1 do
          begin
            OneJo := SO(ArrsJa.S[nIdx]);
            
            WriteLog('��ȡ��ͨԭ���Ͻ����ƻ�:'+OneJo.S['ordername']);

            nO_Valid := 'Y';
            if OneJo.B['is_closed'] then
              nO_Valid := 'N'
            else
              nO_Valid := 'Y';

            ArrsJaSub          := OneJo.A['products'];
            try
              nHasDone := SO(ArrsJaSub.S[0]).D['product_qty']
                          - SO(ArrsJaSub.S[0]).D['remainder'];
              nHasDone := Float2PInt(nHasDone, cPrecision, False) / cPrecision;
              if nHasDone <= 0 then
                nHasDone := 0;
            except
              nHasDone := 0;
            end;
            nStr := MakeSQLByStr([
                SF('B_ID',        OneJo.S['ordername']),
                SF('B_ProID',     OneJo.S['partner_name']),
                SF('B_ProName',   OneJo.S['partner_name']),
                SF('B_StockNo',   SO(ArrsJaSub.S[0]).S['productid']),
                SF('B_StockName', SO(ArrsJaSub.S[0]).S['product_name']),
                SF('B_Value',     SO(ArrsJaSub.S[0]).S['product_qty']),
                SF('B_SentValue', FloatToStr(nHasDone)),
                SF('B_RestValue', FloatToStr(SO(ArrsJaSub.S[0]).D['remainder'])),
                SF('B_BStatus',   nO_Valid),
                SF('B_Date',  Now,sfDateTime)
                ], sTable_OrderBase, '', True);
            FListA.Add(nStr);

            nStr := SF('B_ID', OneJo.S['ordername']);
            nStr := MakeSQLByStr([
                SF('B_ProID',     OneJo.S['partner_name']),
                SF('B_ProName',   OneJo.S['partner_name']),
                SF('B_StockNo',   SO(ArrsJaSub.S[0]).S['productid']),
                SF('B_StockName', SO(ArrsJaSub.S[0]).S['product_name']),
                SF('B_Value',     FloatToStr(SO(ArrsJaSub.S[0]).D['product_qty'])),
                SF('B_SentValue', FloatToStr(nHasDone)),
                SF('B_RestValue', FloatToStr(SO(ArrsJaSub.S[0]).D['remainder'])),
                SF('B_BStatus',   nO_Valid),
                SF('B_Date',  Now,sfDateTime)
                ], sTable_OrderBase, nStr, False);
            FListC.Add(nStr);

            nStr := 'Select * from %s where B_ID = ''%s'' ';
            nStr := Format(nStr, [sTable_OrderBase, OneJo.S['ordername']]);
            FListD.Add(nStr);
            
//            if nO_Valid = 'Y' then
//            begin
//              with FListB do
//              begin
//                Values['Order']         := OneJo.S['ordername'];
//                Values['ProName']       := OneJo.S['partner_name'];
//                Values['ProID']         := OneJo.S['partner_name'];
//                ArrsJaSub               := OneJo.A['products'];
//                Values['StockName']     := SO(ArrsJaSub.S[0]).S['product_name'];
//                Values['StockID']       := SO(ArrsJaSub.S[0]).S['productid'];
//                Values['StockNo']       := SO(ArrsJaSub.S[0]).S['productid'];
//                try
//                  nHasDone := StrToFloatDef(SO(ArrsJaSub.S[0]).S['product_qty'],0)
//                              - StrToFloatDef(SO(ArrsJaSub.S[0]).S['remainder'],0);
//                  nHasDone := Float2PInt(nHasDone, cPrecision, False) / cPrecision;
//                  if nHasDone <= 0 then
//                    nHasDone := 0;
//                except
//                  nHasDone := 0;
//                end;
//                Values['PlanValue']     := SO(ArrsJaSub.S[0]).S['product_qty'];//������
//                Values['EntryValue']    := FloatToStr(nHasDone);//�ѽ�����
//                Values['Value']         := FloatToStr(StrToFloatDef(SO(ArrsJaSub.S[0]).S['remainder'], StrToFloat(SO(ArrsJaSub.S[0]).S['product_qty'])));//ʣ����
//                Values['Model']         := '';//�ͺ�
//                Values['KD']            := '';//���
//                FListA.Add(PackerEncodeStr(FListB.Text));
//              end;
//            end;

            FOut.FData := PackerEncodeStr(FListA.Text);
            Result := True;
          end;
        end;
      end                                                             
      else
      begin
        WriteLog('��ȡ�ɹ�����ʧ��');
        Result     := False;
        FOut.FData :='��ȡ�ɹ�����ʧ��';
        FOut.FBase.FResult := True;
      end;
    end;

    if (FListD.Count > 0) then
    try
      FDBConn.FConn.BeginTrans;
      //��������
      for nIdx:=0 to FListD.Count - 1 do
      begin
        with gDBConnManager.WorkerQuery(FDBConn,FListD[nIdx]) do
        begin
          if RecordCount>0 then
          begin
            gDBConnManager.WorkerExec(FDBConn,FListC[nIdx]);
          end else
          begin
            gDBConnManager.WorkerExec(FDBConn,FListA[nIdx]);
          end;
        end;
      end;
      FDBConn.FConn.CommitTrans;
    except
      if FDBConn.FConn.InTransaction then
        FDBConn.FConn.RollbackTrans;
      raise;
    end;
  finally
    ReStream.Free;
    nDataStream.Free;
    wParam.Free;
  end;
end;

function TBusWorkerBusinessHHJY.GetSaleInfo(var nData: string): Boolean;
var nStr, nProStr, nMatStr, nYearStr: string;
    nO_Valid, nStockName: string;
    nValue: Double;
    nYearMonth,szUrl, nType : string;
    ReJo, OneJo : ISuperObject;
    ArrsJa,ArrsJaSub: TSuperArray;
    wParam: TStrings;
    ReStream,PostStream:TStringstream;
    nIdx: Integer;
    nYear, nMonth, nDays : Word;
    nDataStream: TMsMultiPartFormDataStream;
begin
  Result := True;

  wParam      := TStringList.Create;
  ReStream    := TStringstream.Create('');
  nDataStream := TMsMultiPartFormDataStream.Create;

  FListA.Text := PackerDecodeStr(FIn.FData);
  try
    wParam.Clear;
    wParam.Values['token']     := Ftoken;

    wParam.Values['starttime'] := DateTime2Str(IncMonth(Now,-12));
    wParam.Values['endtime']   := DateTime2Str(Now);

    if FListA.Text <> '' then
      wParam.Values['partner_name'] := FListA.Text;

    nStr := 'token:'+Ftoken;
    WriteLog('��ѯ���۶�����Σ�' + wParam.Text);

    nDataStream.AddFormField('token', Ftoken);
    nDataStream.AddFormField('starttime', DateTime2Str(IncMonth(Now,-12)));


    if FListA.Text <> '' then
    begin
      nDataStream.AddFormField('endtime', DateTime2Str(Now));
      nDataStream.AddFormField('partner_name', Ansitoutf8(FListA.Text));
    end
    else
      nDataStream.AddFormField('endtime', DateTime2Str(Now) + CRLF);
    nDataStream.done;

    szUrl := gSysParam.FWXERPUrl + '/saleorder';
    nStr      := Ansitoutf8(wParam.Text);
    PostStream:= TStringStream.Create(nStr);

    FIdHttp.HTTPOptions:=FIdHttp.HTTPOptions+[hoKeepOrigProtocol];
    FidHttp.ProtocolVersion:= pv1_1;
    FidHttp.Request.ContentType := nDataStream.RequestContentType;
    FidHttp.Post(szUrl, nDataStream, ReStream);
    nStr := ReStream.DataString;
    nStr := UTF8Decode(ReStream.DataString);
    nStr := UnicodeToChinese(nStr);


    WriteLog('���۶������Σ�' + nStr);
    FListA.Clear;
    FListC.Clear;
    FListD.Clear;
    if nStr <> '' then
    begin
      ReJo    := SO(nStr);
      ReJo    := SO(ReJo.S['Response']);
      ArrsJa  := ReJo.A['Infos'];
      if ArrsJa <> nil then
      begin
        if ArrsJa.Length = 0 then
        begin
          WriteLog('���ڼ������۶���');
          Result     := True;
          FOut.FData :='';
          FOut.FBase.FResult := True;
        end
        else
        begin
          for nIdx := 0 to ArrsJa.Length - 1 do
          begin
            OneJo := SO(ArrsJa.S[nIdx]);

            ArrsJaSub  := OneJo.A['products'];

            if Pos('��',SO(ArrsJaSub.S[0]).S['product_uom']) > 0 then
              nType := '��װ'
            else
              nType := 'ɢװ';

            if StrToFloatDef(SO(ArrsJaSub.S[0]).S['remainder'],0) <> 0 then
            begin
              //
            end;
            
            nO_Valid := 'Y';
            if OneJo.B['is_closed'] then
              nO_Valid := 'N'
            else
              nO_Valid := 'Y';

            if (Trim(SO(ArrsJaSub.S[0]).S['specification']) <> 'null')
              and (Trim(SO(ArrsJaSub.S[0]).S['specification']) <> '') then
              nStockName := SO(ArrsJaSub.S[0]).S['specification']
            else
              nStockName := SO(ArrsJaSub.S[0]).S['product_name'];

            nStr := MakeSQLByStr([SF('O_Order', OneJo.S['ordername']),
                SF('O_Factory', ''),
                SF('O_CusName', OneJo.S['partner_name']),
                SF('O_ConsignCusName', ''),
                SF('O_StockName', nStockName),
                SF('O_StockType', nType),
                SF('O_Lading', '������'),
                SF('O_CusPY', GetPinYinOfStr(OneJo.S['partner_name'])),
                SF('O_PlanAmount', FloatToStr(SO(ArrsJaSub.S[0]).D['product_qty'])),        //����
                SF('O_PlanDone', '0'),
                SF('O_PlanRemain', FloatToStr(SO(ArrsJaSub.S[0]).D['remainder'])),          //ʣ��δ������
                SF('O_PlanBegin', StrToDateDef(OneJo.S['confirmation_date'],Now),sfDateTime),
                SF('O_PlanEnd', StrToDateDef(OneJo.S['confirmation_date'],Now),sfDateTime),
                SF('O_Company', ''),
                SF('O_Depart', ''),
                SF('O_SaleMan', OneJo.S['seller']),
                SF('O_Remark', ''),
                SF('O_Price', SO(ArrsJaSub.S[0]).D['price_unit'],sfVal),
                SF('O_Valid', nO_Valid),
                SF('O_Freeze', 0, sfVal),
                SF('O_HasDone', 0, sfVal),
                SF('O_CompanyID', ''),
                SF('O_CusID', OneJo.S['partner_name']),
                SF('O_StockID', SO(ArrsJaSub.S[0]).S['productid']),
                SF('O_PackingID', ''),
                SF('O_FactoryID', ''),
                SF('O_Create', Now,sfDateTime),
                SF('O_Modify', Now,sfDateTime)
                ], sTable_SalesOrder, '', True);
            FListA.Add(nStr);

            nStr := SF('O_Order', OneJo.S['ordername']);
            nStr := MakeSQLByStr([
                SF('O_Factory', ''),
                SF('O_CusName', OneJo.S['partner_name']),
                SF('O_ConsignCusName', ''),
                SF('O_StockName', nStockName),
                SF('O_StockType', nType),
                SF('O_Lading', '������'),
                SF('O_CusPY',      GetPinYinOfStr(OneJo.S['partner_name'])),
                SF('O_PlanAmount', FloatToStr(SO(ArrsJaSub.S[0]).D['product_qty'])),
                SF('O_PlanDone', '0'),
                SF('O_PlanRemain',FloatToStr(SO(ArrsJaSub.S[0]).D['remainder'])),
                SF('O_PlanBegin', StrToDateDef(OneJo.S['confirmation_date'],Now),sfDateTime),
                SF('O_PlanEnd', StrToDateDef(OneJo.S['confirmation_date'],Now),sfDateTime),
                SF('O_Company', ''),
                SF('O_Depart', ''),
                SF('O_SaleMan', OneJo.S['seller']),
                SF('O_Remark', ''),
                SF('O_Price', SO(ArrsJaSub.S[0]).D['price_unit'],sfVal),
                SF('O_Valid',  nO_Valid),
                SF('O_Freeze', 0, sfVal),
                SF('O_HasDone', 0, sfVal),
                SF('O_CompanyID', ''),
                SF('O_CusID',   OneJo.S['partner_name']),
                SF('O_StockID', SO(ArrsJaSub.S[0]).S['productid']),
                SF('O_PackingID', ''),
                SF('O_FactoryID', ''),
                SF('O_Create', Now,sfDateTime),
                SF('O_Modify', Now,sfDateTime)
                ], sTable_SalesOrder, nStr, False);
            FListC.Add(nStr);

            nStr := 'Select * from %s where O_Order = ''%s'' ';
            nStr := Format(nStr, [sTable_SalesOrder, OneJo.S['ordername']]);
            FListD.Add(nStr);
          end;
        end;
      end
      else
      begin
        WriteLog('��ȡ���۶���ʧ��');
        Result     := False;
        FOut.FData :='��ȡ���۶���ʧ��';
        FOut.FBase.FResult := True;
      end;
    end;

    if (FListD.Count > 0) then
    try
      FDBConn.FConn.BeginTrans;
      //��������
      for nIdx:=0 to FListD.Count - 1 do
      begin
        with gDBConnManager.WorkerQuery(FDBConn,FListD[nIdx]) do
        begin
          if RecordCount>0 then
          begin
            gDBConnManager.WorkerExec(FDBConn,FListC[nIdx]);
          end else
          begin
            gDBConnManager.WorkerExec(FDBConn,FListA[nIdx]);
          end;
        end;
      end;
      FDBConn.FConn.CommitTrans;
    except
      if FDBConn.FConn.InTransaction then
        FDBConn.FConn.RollbackTrans;
      raise;
    end;
  finally
    ReStream.Free;
    nDataStream.Free;
    PostStream.Free;
    wParam.Free;
  end;
end;

function TBusWorkerBusinessHHJY.GetLoginToken(var nData: string): Boolean;
var
  nStr, szUrl: string;
  ReJo, ReSubJo : ISuperObject;
  ArrsJa: TSuperArray;
  wParam: TStrings;
  ReStream:TStringstream;
begin
  Result   := True;
  wParam   := TStringList.Create;
  ReStream := TStringstream.Create('');

  try
    wParam.Clear;
    wParam.Values['username']:= FIn.FData;
    wParam.Values['password']:= FIn.FExtParam;
    nStr := 'username:'+FIn.FData+'password'+FIn.FExtParam;
    WriteLog('��¼�ӿ���Σ�' + nStr);

    szUrl := gSysParam.FWXERPUrl+'/login';
    WriteLog('��¼�ӿڵ�ַ��' + szUrl);
    FidHttp.Request.ContentType := 'application/x-www-form-urlencoded';
    FidHttp.Post(szUrl, wParam, ReStream);
    nStr := ReStream.DataString;
    nStr := UTF8Decode(ReStream.DataString);
    nStr := UnicodeToChinese(nStr);

    WriteLog('��¼�ӿڳ��Σ�' + nStr);
    if nStr <> '' then
    begin
      ReJo    := SO(nStr);
      ReSubJo := SO(ReJo.S['Response']);
      if ReSubJo.S['token'] <> '' then
      begin
        Ftoken := ReSubJo.S['token'];
        WriteLog('���ŵ�¼Token��' + Ftoken);
        Result := True;
        FOut.FData := sFlag_Yes;
        FOut.FBase.FResult := True;
      end
      else
      begin
        WriteLog('���ŵ�¼ʧ�ܣ�' + ReSubJo.S['Message']);
        Result     := True;
        FOut.FData := ReSubJo.S['Message'];
        FOut.FBase.FResult := True;
      end;
    end;
  finally
    ReStream.Free;
    wParam.Free;
  end;
end;

function TBusWorkerBusinessHHJY.UnicodeToChinese(inputstr: string): string;
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

initialization
  gBusinessWorkerManager.RegisteWorker(TBusWorkerBusinessHHJY, sPlug_ModuleBus);
end.
