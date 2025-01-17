﻿#include <oxstd.oxh>
#import <packages/PcGive/pcgive_ects>

#include <.\Classes\ClasseCATS_Custom.ox>
//	mPhi: matrix dos coeficientes. Inicialmente uma matriz zerada [iQtdVarDependente x iQtdVarDependente*iQtdLags];
//	iValue: vParamValues - Valor efetivo dos parametros
//	sName: asParamNames - Nome dos parametros
//	iQtdLags: Quantidade de lags
//	iRegDependente: Regiao dependente na regressao
//	sVarSufix: Sufixo do nome da variavael "D_R"
ProcessoPhi(mPhi, const iValue, const sName, const iQtdLags, const iRegDependente, const sVarSufix, const asTipo) {
    println("Processo Phi iniciado");
    decl iContRows, iContCols, iContVar, sParamName, index;

    for (iContRows = 0; iContRows < sizeof(asTipo); ++iContRows) {
        // Preenchimento da matrix Lambda
        for (iContCols = 0; iContCols < iQtdLags; ++iContCols) {
            for (iContVar = 0; iContVar < sizeof(asTipo); ++iContVar) {
                // determina o nome das variaveis
                sParamName = sprint(sVarSufix, iRegDependente, "_", asTipo[iContVar], "_", iContCols + 1, "@", sVarSufix, iRegDependente, "_", asTipo[iContRows]);
                index = strfind(sName, sParamName);

                if (index > -1) {
                    mPhi[iContRows][(sizeof(asTipo)*iContCols) + iContVar] = iValue[index];
                }
            } // Fim: iContVar (looping nos tipos para as colunas (colunas pares e impares))
        } // Fim: iContCols (looping nos lags)
    } // Fim: iContRows (looping nos tipos para as linhas)
    println("Processo Phi finalizado");
//	println(mPhi);
    return mPhi;
}



//	mLambda: matrix dos coeficientes. Inicialmente uma matriz zerada [iQtdVarDependente x iQtdVarDependente*(iQtdLags+1)]
//	iValue: vParamValues - Valor efetivo dos parametros
//	sName: asParamNames - Nome dos parametros
//	iQtdLags: Quantidade de lags
//	iRegDependente: Regiao dependente na regressao
//	sVarSufix: Sufixo do nome da variavael "D_R"
ProcessoLambda(mLambda, const iValue, const sName, const iQtdLags, const iRegDependente, const sVarSufix, const asTipo) {
    println("Processo Lambda iniciado");
    decl iContRows, iContCols, iContVar, sParamName, index;
    // asTipo = {"Admitidos", "Desligados"};

    for (iContRows = 0; iContRows < sizeof(asTipo); ++iContRows) {
        // Preenchimento da matrix Lambda
        for (iContCols = 0; iContCols <= iQtdLags; ++iContCols) {
            for (iContVar = 0; iContVar < sizeof(asTipo); ++iContVar) {
                // determina o nome das variaveis
                if (iContCols == 0) {
                    // Determina o nome do parametro sem lag
                    sParamName = sprint(sVarSufix, "star_", asTipo[iContVar], "@", sVarSufix, "R", iRegDependente, "_", asTipo[iContRows]);
                } else {
                    // Determina o nome do parametro COM lag
                    sParamName = sprint(sVarSufix, "star_", asTipo[iContVar], "_", iContCols, "@", sVarSufix, "R", iRegDependente, "_", asTipo[iContRows]);
                }

                index = strfind(sName, sParamName);

                if (index > -1) {
                    mLambda[iContRows][(sizeof(asTipo)*iContCols) + iContVar] = iValue[index];
                }
            } // Fim: iContVar (looping nos tipos para as colunas (colunas pares e impares))
        } // Fim: iContCols (looping nos lags)
    } // Fim: iContRows (looping nos tipos para as linhas)
    println("Processo Lambda finalizado");
//	println(mLambda);
    return mLambda;
}


//	mU: matriz de coeficientes para ser preenchida (inicialmente deve ser uma matriz de zeros)
//	iValue: vParamValues - Valor efetivo dos parametros
//	sName: asParamNames - Nome dos parametros
//	iQtdLags: Quantidade de lags
//	iRegDependente: Regiao dependente na regressao
//	sVarSufix: Sufixo do nome da variavael "D_R"
ProcessoU(mU, const iValue, const sName, const iQtdLags, const iRegDependente, const sVarSufix, const asTipo) {
    println("Processo U iniciado");
    decl iContRows, iContCols, iContVar, sParamName, index, asConstants;
    // asTipo = {"Admitidos", "Desligados"};
    asConstants = {"Constant", "CSeasonal", "CSeasonal_1", "CSeasonal_2", "CSeasonal_3", "CSeasonal_4", "CSeasonal_5", "CSeasonal_6", "CSeasonal_7", "CSeasonal_8", "CSeasonal_9", "CSeasonal_10"};

    for (iContRows = 0; iContRows < sizeof(asTipo); ++iContRows) {
        // Preenchimento da matrix Lambda
        for (iContCols = 0; iContCols < sizeof(asConstants); ++iContCols) {
            // determina o nome das variaveis
            sParamName = sprint(asConstants[iContCols], "@", sVarSufix, iRegDependente, "_", asTipo[iContRows]);
            index = strfind(sName, sParamName);

            if (index > -1) {
                mU[iContRows][iContCols] = iValue[index];
            }
        } // Fim: iContCols (looping nos lags)
    } // Fim: iContRows (looping nos tipos para as linhas)
    println("Processo U finalizado");
    return mU;
}

//	iValue: vParamValues - Valor efetivo dos parametros
//	sName: asParamNames - Nome dos parametros
//	iRegDependente: Regiao dependente na regressao
//	sVarSufix: Sufixo do nome da variavael "D_R"
ProcessoIIS(const iValue, const sName, const iRegDependente, const sVarSufix, const anoIni, const anoFim, const asTipo) {
    //(const iValue, const sName, const iQtdLags, const iRegDependente)
    println("Processo Extracao da matriz de saturacao (IIS)");
    decl nContTipo, nContTotal, iContVar, sParamName, nCountAno, nCountMes, mReturn, index;
    mReturn = zeros(2, ((anoFim - anoIni) + 1) * 12);
    // asTipo = {"Admitidos", "Desligados"};
    //Faz um looping por todas as datas, procura a respectiva dummy e se achar adiciona o valor a tabela.
    nContTotal = 0;

    for (nCountAno = anoIni; nCountAno <= anoFim; ++nCountAno) {
        for (nCountMes = 1; nCountMes <= 12; ++nCountMes) {
            //println(sprint("I:",nCountAno,"(",nCountMes,")"));
            for (nContTipo = 0; nContTipo < sizeof(asTipo); ++nContTipo) {
                index = find(sName, sprint("I:", nCountAno, "(", nCountMes, ")@", sVarSufix, iRegDependente, "_" , asTipo[nContTipo]));

                // caso tenha achado o indice atualiza a tabela
                if (index >= 0) {
                    mReturn[nContTipo][nContTotal] = iValue[index];
                }
            }
            ++nContTotal;
        }
    }
//	println(mReturn);
    return mReturn;
}



//	iValue: vParamValues - Valor efetivo dos parametros
//	sName: asParamNames - Nome dos parametros
//	iRegDependente: Regiao dependente na regressao
//	sVarSufix: Sufixo do nome da variavael "D_R"
ProcessoPILongRun(const iValue, const sName, const iRegDependente, const sVarSufix) {
    //(const iValue, const sName, const iQtdLags, const iRegDependente)
    println("Processo Extracao da matriz de longo prazo");
    decl nContTipo, nContTotal, iContVar, sParamName, asTipo, nCountAno, nCountMes, mReturn, index;
    mReturn = zeros(2, 2);
    asTipo = {"Admitidos", "Desligados"};

    for (nContTipo = 0; nContTipo < sizeof(asTipo); ++nContTipo) {
        index = find(sName, sprint("betaZ_", "1", "_", 1, "@", sVarSufix, iRegDependente, "_" , asTipo[nContTipo]));

        // caso tenha achado o indice atualiza a tabela
        if (index >= 0) {
            mReturn[nContTipo][0] = iValue[index];
        }

        index = find(sName, sprint("betaZ_", "2", "_", 1, "@", sVarSufix, iRegDependente, "_" , asTipo[nContTipo]));

        // caso tenha achado o indice atualiza a tabela
        if (index >= 0) {
            mReturn[nContTipo][1] = iValue[index];
        }
    }
	// println(mReturn);
    return mReturn;
}

//	iValue: vParamValues - Valor efetivo dos parametros
//	sName: asParamNames - Nome dos parametros
//	iQtdLags: Quantidade de lags
//	iRegDependente: iCont - identificador da variavel dependente
//	sVarSufix: Sufixo do nome da variavael "D_R"
//	sMacroSufix: Sufixo do nome da variavael macro {"D"}
//	aMacoVarNames: Nome d variavel macro
ProcessoMacroVariables(const iValue, const sName, const iQtdLags, const iRegDependente, const sVarSufix, const sMacroSufix, const aMacoVarNames, const asTipo) {
    //vParamValues, asParamNames, iQtdLags, iCont, sVarSufix, aMacoVarNames
    println("Processo Extracao das variaveis macroeconomicas (matrix de longo Prazo inclusive)");
    decl nContTipo, nContLag, nContVar, nContTotal, asTipo, mReturn, sParamName, index;//nContTotal, iContVar, sParamName, , nCountAno, nCountMes, , ;
    //println("sName:", sName);
    mReturn = zeros(2, (rows(aMacoVarNames) * (iQtdLags + 1)));
    //asTipo = {"Admitidos", "Desligados"};

    //println("%r", asTipo, "%c", {"D_Selic", "D_IPCA", "D_PIM", "D_Selic_1", "D_IPCA_1", "D_PIM_1", "D_Selic_2", "D_IPCA_2", "D_PIM_2"},  mReturn);

    for (nContTipo = 0; nContTipo < sizeof(asTipo); ++nContTipo) {
        nContTotal = 0;

        for (nContLag = 0; nContLag <= iQtdLags; ++nContLag) {
            for (nContVar = 0; nContVar < rows(aMacoVarNames); ++nContVar) {
                if (nContLag == 0) {
                    sParamName = sprint(sMacroSufix, aMacoVarNames[nContVar], "@", sVarSufix, iRegDependente, "_", asTipo[nContTipo]);
                    //	D_R5_Desligado
                } else {
                    sParamName = sprint(sMacroSufix, aMacoVarNames[nContVar], "_", nContLag, "@", sVarSufix, iRegDependente, "_", asTipo[nContTipo]);
                }

                //println(sParamName);
                index = find(sName, sParamName);

                // caso tenha achado o indice atualiza a tabela
                if (index >= 0) {
                    mReturn[nContTipo][nContTotal] = iValue[index];
                }

                ++nContTotal;
            } // fim nContVar
        } // fim nContLag
    } // fim nContTipo
//	println("%r", asTipo, "%c", {"D_Selic", "D_IPCA", "D_PIM", "D_Selic_1", "D_IPCA_1", "D_PIM_1", "D_Selic_2", "D_IPCA_2", "D_PIM_2", "betaMacro"},  mReturn);
    //println(mReturn);
    return mReturn;
}

/**
* Funcao de busca das variaveis, as regioes devem ser numeradas
* sequencialmente, mas podem ter um prefixo e um posfixo.
* ex: R_1_OIL
*
* @param    iQtdRegioes Quantidade de regioes no GVAR
* @param    sVarPrefix Prefixo do nome da variavel 
* @param    sVarPosfix Posfixo do nome da variavel
*
* @return   Colunas do banco de dados com as variaveis de todas as regioes. 
*/
GetRegionNames(const iQtdRegioes, const sVarPrefix, const sVarPosfix) {
    decl nCont, aNames;
    
    for (nCont = 1; nCont <= iQtdRegioes; ++nCont) {
        if (nCont == 1) {
            aNames = {sprint(sVarPrefix, nCont, sVarPosfix)};
        } else {
            aNames = aNames ~ {sprint(sVarPrefix, nCont, sVarPosfix)};
        }
    }
    return aNames;
}

/**
*
* @param    mRankMatrix
*
* @return    
*/
EstimateRank(const mRankMatrix, const col){

    println("RANK TABLE");
    println(mRankMatrix);

	decl iRank;
    for(decl irow = 0; irow < rows(mRankMatrix); irow++) {
        iRank = mRankMatrix[irow][1];
        // println("myiRank: ", iRank);
        // println("myValue: ", mRankMatrix[irow][col]);
		if(mRankMatrix[irow][col] > 0.01){
			break;
		} else {
			iRank = iRank + 1;
		}
	}
    return(iRank);
}


// EstimateRank2(const mRankMatrix, const col){

//     println("RANK TABLE");
//     println(mRankMatrix);

// 	decl iRank;
//     for(decl irow = 0; irow < rows(mRankMatrix); irow++) {
// 		// iRank = mRankMatrix[0][irow][1];
//         iRank = mRankMatrix[irow][1];
//         println("myiRank: ", iRank);
//         println("myValue: ", mRankMatrix[irow][col]);
// 		if(mRankMatrix[irow][col] > 0.05){
// 			break;
// 		} else {
// 			iRank = iRank + 1;
// 		}
// 	}
//     return(iRank);
// }


//GetBetaEstimative(const mBeta, const iRank){
//	println(mBeta);
//    decl ret;
//	if (iRank == 0){
//		ret = zeros(4, 1);
//	} else {
//		ret = mBeta[][0:iRank-1];
//	}
//	return ret;
//}
//
//SaveBetaEstimative(const spath, const mBeta, const iRank){
//	decl mbetaTransp = GetBetaEstimative(mBeta, iRank);
//	savemat(spath, mbetaTransp');
//}


main() {
    // Arquivo de configuracao
    #include "./Config.ini";

	/*
    println("Carregando dados de macrovariaveis");
    decl mMacroData;
    decl daBaseMacro = new Database();
    daBaseMacro.Load(txDbaseMacroVariables);
    //print( "%c", daBaseMacro.GetAllNames(), "%cf", daBaseMacro.GetAll());
    println(" Carregando dados das colunas: ", aMacroVarNames);
    mMacroData = daBaseMacro.GetVar(aMacroVarNames);
    
    //print( "%c", aMacroVarNames, "%cf", mMacroData[0:9][]);
    delete daBaseMacro;
    println("Macrovariaveis carregadas");

    println("Carregando matrix de pessos W");
    decl mW;

    mW = loadmat(sprint(txMatPathW_Matrix, "PIB_PC_1.mat"));

    println("*** Iniciando estimacao dos modelos *** \n");
    
    // iCont : Contador da regiao atual
    decl iCont;

	// Carrega a informação de qual o rank de cada região 
	decl mRankRegions;
	println("Lista de ranks das regioes: ", sprint("./mat_files/", "rankOfRegions.mat"));
    mRankRegions = loadmat(sprint("./mat_files/", "rankOfRegions.mat"));
    // println(mRankRegions);
	*/
		
    for (iCont = 1; iCont <= iQtdRegioes; ++iCont) {

        // FOR DEBUG ONLY
        // zero cointegracao:  13,52,77, 99, 114, 115
		// if( any(<12,16> .== iCont)){
		// println("SKIP: Regiao ", iCont);
        //      continue;
        // }
       
		// print Headder
        println("\n\n*****************************************");
        println("             Regiao ", iCont);
        println("*****************************************\n\n");
        
        // Inicio um nomo objeto do tipo database
        decl modelDatabase = new Database();
        
        // Matriz de selecao dos vetores de cointegracao
        decl mRankMatrix; 
        
         // Rank selecionado
        decl iRank;
        
        println("\nCarregando base de dados para regiao ", iCont);
        modelDatabase.Load(txDbase);

        println("\tPeriodo da base de dados");
        println("\tData inicial: ", modelDatabase.GetYear1(), "-", modelDatabase.GetPeriod1());
        println("\tData final: ", modelDatabase.GetYear2(), "-", modelDatabase.GetPeriod2());

        // As Variaveis Star sao uma combinacao linear das variaveis esternas.
        println("(1) Iniciando construcao das variaveis star para a regiao ", iCont);

        // mData: Matrix com as variaveis
        // beta: vetores de cointegracao.
        decl mData, mBeta;
        mBeta =0;

        println("\tAdicionando variavel star da regiao ", iCont);
        decl iContador;
        for (iContador = 0; iContador < columns(aVarDependenteNames); ++iContador) {
            
            mData = modelDatabase.GetVar(GetRegionNames(iQtdRegioes, "R_", sprint("_", aVarDependenteNames[iContador])));
           	modelDatabase.Append(mData * mW[][iCont - 1], sprint("star_", aVarDependenteNames[iContador]));
        }
        println("\tConcluido construcao das variaveis star para a regiao ", iCont);

        println("(2) Iniciando construcao da variavel Delta para a regiao ", iCont);
        for(iContador = 0; iContador < columns(aVarDependenteNames); ++iContador) {
            // Adiciona a variavel em primeira Diferenca
            mData =	modelDatabase.GetVar(sprint("R_", iCont, "_", aVarDependenteNames[iContador]));
            modelDatabase.Append(diff(mData), sprint("D_R_", iCont, "_", aVarDependenteNames[iContador]));

            // Adiciona a variavel Star em primeira diferenca
            mData =	modelDatabase.GetVar(sprint("star_", aVarDependenteNames[iContador]));
            modelDatabase.Append(diff(mData), sprint("D_star", "_", aVarDependenteNames[iContador]));
        }
        println("\tConcluido construcao da variavel Delta para a regiao ", iCont);

		// CONTRUCAO DA MATRIZ DE LONGO PRAZO
        println("(3) Iniciando construcao da variavel beta*Z (Cointegracao) para a regiao ", iCont);

        // procedimento de determinacao do vetor de cointegracao foi feito separadamente
        // Leitura do vetor de cointegracao
        beta = loadmat(sprint(txCoIntMatPath, sprint("Weak2_CoInt_R", iCont, ".mat")));
        
        // Construcao dos nomes do vetor de cointegracao
        decl asBetaZ;
        for(decl i=1; i<=rows(beta); i++){
            if(i==1){
                asBetaZ = {sprint("betaZ_", i)};    
            } else {
                asBetaZ =  asBetaZ ~ {sprint("betaZ_", i)};    
            }
            // println("rows: ", asBetaZ);
        }
        
// Adiciono a(s) variavei(s) beta*Z ao banco de dados

        for(iContador = 0; iContador < columns(aVarDependenteNames); ++iContador) {
			 if(iContador == 0){
			println("Getting for betaZ: ", sprint("R_", iCont, "_", aVarDependenteNames[iContador]));
            mData =	modelDatabase.GetVar(sprint("R_", iCont, "_", aVarDependenteNames[iContador]));
			} else {
			
			 mData = mData ~ model.GetVar(sprint("R", iCont, "_Desligados"));
			



        }
        for(iContador = 0; iContador < columns(aVarDependenteNames); ++iContador) {
            println("append: ", sprint("star", "_", aVarDependenteNames[iContador]));
            modelCats.Select("Y", {sprint("star", "_", aVarDependenteNames[iContador]), 0, 0});
        }

			 

		
            mData =	modelDatabase.GetVar(sprint("R_", iCont, "_", aVarDependenteNames[iContador]));
            modelDatabase.Append(diff(mData), sprint("D_R_", iCont, "_", aVarDependenteNames[iContador]));

            // Adiciona a variavel Star em primeira diferenca
            mData =	modelDatabase.GetVar(sprint("star_", aVarDependenteNames[iContador]));
            modelDatabase.Append(diff(mData), sprint("D_star", "_", aVarDependenteNames[iContador]));
        }




        
        model.Append(mData * beta', asBetaZ);
		
        delete asBetaZ;
        
        println("\tIniciando determinacao do vetor de cointegracao (beta) a regiao ", iCont);
        // Inicio um objeto do CATS (Cointegration)
    	decl modelCats = new GVAR_CATS();
	
		// modelCats.Resample(12, 1995, 1);
        // mData =	modelDatabase.GetVar("date_2");
        // modelCats.Append(mData, sprint("DB_DATE"));

        // modelCats.SetSample ( const iYear1 , const iPeriod1 , const iYear2 , const iPeriod2 )
        // modelCats.SetSample ( 2004, 19, 2021, const iPeriod2 )

        /* Adiciona a variavel em primeira Diferenca */
        for(iContador = 0; iContador < columns(aVarDependenteNames); ++iContador) {
            mData =	modelDatabase.GetVar(sprint("R_", iCont, "_", aVarDependenteNames[iContador]));
            modelCats.Append(mData, sprint("R_", iCont, "_", aVarDependenteNames[iContador]));
        }

        // Adiciona a variavel Star em primeira diferenca
        for(iContador = 0; iContador < columns(aVarDependenteNames); ++iContador) {
            mData =	modelDatabase.GetVar(sprint("star_", aVarDependenteNames[iContador]));
            modelCats.Append(mData, sprint("star", "_", aVarDependenteNames[iContador]));
        }

        // Adiciona a variavel macroeconomicas (exogenas) 
        for(iContador = 0; iContador < columns(aMacroVarNames); ++iContador) {
            mData =	modelDatabase.GetVar(sprint(aMacroVarNames[iContador]));
            modelCats.Append(mData, sprint(aMacroVarNames[iContador]));
        }

        // Adiciona a variaveis dummies
        // for(iContador = 1; iContador < 12; ++iContador) {
        //     mData =	modelDatabase.GetVar(sprint("M", iContador));
        //     modelCats.Append(mData, sprint("M", iContador));
        // }
        

    	// Adiciona as variaveis X como exogenas
        for(iContador = 0; iContador < columns(aVarDependenteNames); ++iContador) {
            println("append: ", sprint("R_", iCont, "_", aVarDependenteNames[iContador]));
            modelCats.Select("Y", {sprint("R_", iCont, "_", aVarDependenteNames[iContador]), 0, 0});
        }
        for(iContador = 0; iContador < columns(aVarDependenteNames); ++iContador) {
            println("append: ", sprint("star", "_", aVarDependenteNames[iContador]));
            modelCats.Select("Y", {sprint("star", "_", aVarDependenteNames[iContador]), 0, 0});
        }

        for(iContador = 0; iContador < columns(aMacroVarNames); ++iContador) {
            println("append: ", sprint(aMacroVarNames[iContador]));
            modelCats.Select("X", {sprint(aMacroVarNames[iContador]), 0, 0});
        }

        // for(iContador = 1; iContador < 12; ++iContador) {
        //     println("append: ", sprint("M", iContador));
        //     modelCats.Select("X", {sprint("M", iContador), 0, 0});
        // }

        modelCats.Lags(iQtdLags, iQtdLags, iQtdLags);

	    // Rank inicial (mudar para a quantidade de variaveis.)
	    modelCats.I1Rank(6);

        // Tipo de cointegracao CIMEAN: Constante no espaço de cointegracao.
        // mode	string: one of "NONE","CIMEAN","DRIFT","CIDRIFT".
        // Equivalently, use the strings "H_z","H_c","H_lc","H_l", or the predefined constants CATS::NONE, CATS::CIMEAN, CATS::DRIFT, CATS::CIDRIFT.
        modelCats.Trend("DRIFT");

        // Inclui seasonal centradas
        // modelCats.Seasonals(1);

        // fixa a amostra
        // modelCats.SetSelSample(1995, 1, 1998, 12);
        
        // tipo de metodo RRR: Reduced Rank Regression
        modelCats.SetMethod("RRR");

        // set print to false
        modelCats.SetPrint(TRUE);

        // Estima o modelo.
        // modelCats.SaveIn7(sprint("R_", iCont, "_database"));
        modelCats.Estimate();

        modelCats.TestSummary();

        // Escolhe o Rank 
        mRankMatrix = modelCats.I1RankTable();
        iRank = EstimateRank(mRankMatrix, 6);
        println("RANK ESTIMADO NORMAL: ", iRank);
        iRank = EstimateRank(mRankMatrix, 7);
        println("RANK ESTIMADO NORMAL_BARLET: ", iRank);

        // modelCats.PrintI1Rank();
        // Estima vetores do cointegração por bootstrap
       	// if(any(<94, 95, 97, 98, 105, 107, 108, 109, 110> .== iCont)){
            mRankMatrix = modelCats.BootstrapRankTest();
            iRank = EstimateRank(mRankMatrix[0], 7);
            println("RANK ESTIMADO BOOSTRAP: ", iRank);
        // }

        if(iRank == 0){
            println("RANK ZERO DETECTADO, MUDANDO PARA RANK=1");
            iRank=1;
        }

        mBeta = modelCats.GetBeta();
        // println(mRankMatrix);

        // Se o rank for maior que dois Automaticamente teremos de modelar as variaveis no modelo dominante
        if(iRank > 6){
            //  salva a estimacao do beta PARA AS REGIOES COM MAIS DE 3 VETORES DE COINTEGRACAO
            modelCats.SaveBetaEstimative(sprint(txCoIntMatPath, sprint("Dominant3_CoInt_R", iCont, ".mat")), mBeta, iRank);
        } else {
			//  Restima o modelo com os dados de cointegracao.
            println("RANK TOTAL: ",iRank);
            modelCats.I1Rank(iRank);
            modelCats.Estimate();
            //modelCats.BootstrapRankTest();

            modelCats.SetPrint(TRUE);
            
            // Estima a exogeniedade fraca
            println("TESTE A EXOGENIEDADE FRACA: Regiao ", iCont);
			if(iRank == 1){
                modelCats.Restrict({"[beta]","[alpha]","* * * 0 0 0"});
            } else if(iRank == 2){
                modelCats.Restrict({"[beta]","[alpha]","* * * 0 0 0", "* * * 0 0 0"});
            } else if(iRank == 3) {
                modelCats.Restrict({"[beta]","[alpha]","* * * 0 0 0", "* * * 0 0 0", "* * * 0 0 0"});
            } else if(iRank == 4) {
                modelCats.Restrict({"[beta]","[alpha]","* * * 0 0 0", "* * * 0 0 0", "* * * 0 0 0", "* * * 0 0 0"});
            } else if(iRank == 5) {
                modelCats.Restrict({"[beta]","[alpha]","* * * 0 0 0", "* * * 0 0 0", "* * * 0 0 0", "* * * 0 0 0", "* * * 0 0 0"});
            } else {
                println("DEU MERDA!");
            }
        	modelCats.BootstrapRestrictions();

            // println("TESTE A SEPARABILIDADE ", iCont, " (hail mary)");
			// modelCats.Restrict({"[beta]","* * * *", "0 0 * *","[alpha]","* * 0 0","0 0 * *"});
        	// modelCats.BootstrapRestrictions();
            // println("a", modelCats.GetAlpha());

            modelCats.SaveBetaEstimative(sprint(txCoIntMatPath, sprint("Weak2_CoInt_R", iCont, ".mat")), mBeta, iRank);
        }

        // Guarda o valor do Beta
        // mBeta = model.GetBeta();

        delete modelCats;
        delete modelDatabase;

        // Apago variaveis que nao serao mais utilizadas
        delete mData, mBeta;
    } // for (iCont = 1; iCont <= iQtdRegioes; ++iCont)

    delete mW;
        // Faz os calculos para determinar as matrizes Wi
        decl Wi_aux1, Wi_aux2, Wi;
        Wi_aux1 = zeros(1, iQtdRegioes);
        Wi_aux1[][iCont - 1] = 1;
        Wi_aux1 = Wi_aux1 ** unit(iQtdVarDependente);
        Wi_aux2 = mW[][iCont - 1]';
        Wi_aux2 = Wi_aux2 ** unit(iQtdVarDependente);
        Wi = Wi_aux1 | Wi_aux2;
        savemat(sprint(txMatPathW_Matrix, "W", iCont, ".mat"), Wi);
    println("*** Fim da estimacao dos modelos regionais *** \n");
} // End of main()
