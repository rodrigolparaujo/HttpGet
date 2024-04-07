#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWBROWSE.CH"

User Function EXPLO002()
	Local oPanel
	Local oUrl
	Local cUrl := Space(254)
	Local oDlg

	Private aItens := {}
	Private oBrowse1

	DEFINE MSDIALOG oDlg Title "Lista de Produtos" FROM 0,0 TO 300,600 PIXEL
		oPanel:= tPanel():New(00,00,,oDlg,,,,,,100,26)
		oPanel:Align := CONTROL_ALIGN_TOP

		oUrl:= TGet():New( 003, 005,{|u| if(PCount()>0,cUrl:=u,cUrl)},oPanel,255, 010,Nil,{||  },0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"",cUrl,,,,,,,"Digite o endereço com o arquivo: ",1 )
		oBtnBuscar:= tButton():New(011,265,'Baixar' ,oPanel, {|| Baixar(cUrl)  },35,12,,,,.T.)  
		
		//Cria o grid que receberá o conteudo do arquivo
        oBrowse1:= TCBrowse():New( 0,0, 400, 300, , , , oDlg,,,,,,,,,,,,.F.,,.T.,,,,.T.,.T.)
        oBrowse1:AddColumn(TCColumn():New("Codigo"		, {|| aItens[oBrowse1:nAt,01]},"@!"         ,,,"CENTER", 035,.F.,.F.,,{|| .F. },,.F., ) )
        oBrowse1:AddColumn(TCColumn():New("Descricao"	, {|| aItens[oBrowse1:nAt,02]},"@!"         ,,,"LEFT"  , 100,.F.,.F.,,{|| .F. },,.F., ) )
        oBrowse1:AddColumn(TCColumn():New("Valor" 		, {|| aItens[oBrowse1:nAt,03]},"@E 999.9999",,,"RIGHT" , 040,.F.,.F.,,{|| .F. },,.F., ) )
        oBrowse1:AddColumn(TCColumn():New("Status" 		, {|| aItens[oBrowse1:nAt,04]},"@!"         ,,,"CENTER", 040,.F.,.F.,,{|| .F. },,.F., ) )
        oBrowse1:SetArray(aItens)
        oBrowse1:bWhen        :={|| Len(aItens) > 0 }
        oBrowse1:lHScroll     := .F.
        oBrowse1:Align        := CONTROL_ALIGN_ALLCLIENT
        oBrowse1:Refresh()

	ACTIVATE MSDIALOG oDlg CENTERED
Return

Static Function Baixar(cUrl)
	Local cTexto	:= ""
	Local cHtml		:= ""
	Local nHtml		:= 0
	Local nArquivo	:= 0
	Local cArquivo 	:= "\system\arquivoremoto.csv"
	Local nHdl

	if Empty(cUrl)
		Alert("Digite o endereço!")
		Return
	Endif

	//http://tdn.totvs.com/display/tec/HTTPGet
	Begin Sequence
	   
	   MsAguarde({|| cTexto:= HttpGet(cUrl)  },"Aguarde...")
	   
	End Sequence	

	if Empty(cTexto)
		Alert("O arquivo não existe ou está vazio!")
		Return
	Endif

	cTexto := Upper(cTexto)
	nHtml := At(cHtml, cTexto)
	
	If nHtml == 0
		
		nArquivo := FCreate( cArquivo, 0 ) //Criação do arquivo
		FWrite( nArquivo , cTexto)			//Populando o arquivo com o conteudo obtido
		fClose( nArquivo )					//Fechando o arquivo
	
		nHdl := fOpen(cArquivo) //Abertura do arquivo texto
		If nHdl == -1
			IF FERROR()== 516
				ALERT("Feche o arquivo, antes de importar.")
				Return
			EndIF
		EndIf
		FSEEK(nHdl,0,0)		//Posiciona no Inicio do Arquivo   
		fClose(nHdl)		//Fecha o Arquivo
		
		 
		FT_FUse(cArquivo)  //abre o arquivo
		FT_FGOTOP()         //posiciona na primeira linha do arquivo
		aItens:={}
		While !FT_FEOF()	//Percorre o arquivo linha a linha
			AADD(aItens,Separa(FT_FREADLN(),";",.T.))	//Verifica se existe delimitador 
														//e separa em coluna dentro do array 
			FT_FSKIP()	//passa para proxima linha
		EndDo
		FT_FUse()  //Abre e fecha um arquivo texto para disponibilizar às funções FT_F*
		fClose(nHdl) //Fecha o arquivo
	
		if Len(aItens) > 0 //Se existir informações no array atualiza o grid
			oBrowse1:SetArray(aItens)
			oBrowse1:Refresh()
		Endif
	Endif
Return

