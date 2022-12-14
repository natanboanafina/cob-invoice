       IDENTIFICATION                  DIVISION.
       PROGRAM-ID.INVOICE-PROG.
      *================================================================*
      *    AUTHOR      : NATAN BOANAFINA.                              *
      *    ENTERPRISE  : NOT APPLICABLE                                *
      *    PROFESSOR   : IVAN PETRUCCI                                 *
      *    DATE        : 24/11/2022                                    *
      *                                                                *
      *----------------------------------------------------------------*
      *    PURPOSE     : SEARCH FOR CLIENTS VIA ID, SAVE THEIR GOODS   *
      *    BOUGHT INTO A NEW FILE AND SHOW IT UP.                      *
      *                                                                *
      *----------------------------------------------------------------*
      *    FILES       :                                               *
      *    DDNAME                 I/O                 COPY/BOOK        *
      *    CLIENTS                 I                      -            *
      *    SHOPPING                I                      -            *
      *    INVOICE                 O                      -            *
      *----------------------------------------------------------------*
      *================================================================*
       ENVIRONMENT                     DIVISION.
      *----------------------------------------------------------------*
       CONFIGURATION                   SECTION.
       SPECIAL-NAMES.
           DECIMAL-POINT IS COMMA.

      *----------------------------------------------------------------*
       INPUT-OUTPUT                    SECTION.
       FILE-CONTROL.
      *=================================================================
      *                    SELECT CLIENTES.DAT
      *=================================================================
           SELECT CLIENTS ASSIGN TO "C:\Cobol\task3\data\CLIENTES.DAT"
                              FILE STATUS IS FS-CLIENTS-STATUS.

      *=================================================================
      *                    SELECT COMPRAS.DAT
      *=================================================================
           SELECT SHOPPING ASSIGN TO "C:\Cobol\task3\data\COMPRAS.DAT"
                               FILE STATUS IS FS-SHOPPING-STATUS.

      *=================================================================
      *                    SELECT NF.DAT
      *=================================================================
           SELECT INVOICE ASSIGN TO "C:\Cobol\task3\data\NF.DAT"
                              FILE STATUS IS FS-INVOICE-STATUS.

      *----------------------------------------------------------------*
      *================================================================*
      *----------------------------------------------------------------*
       DATA                            DIVISION.
       FILE                            SECTION.
      **================== FD CLIENTS BEGINNING =======================*
       FD  CLIENTS.
       01  RG-CLIENTS.
           05 RG-CLIENTS-ID        PIC 9(05).
           05 RG-CLIENTS-NAME      PIC X(20).

      **================= FD SHOPPING BEGINNING =======================*
       FD  SHOPPING.
       01  RG-SHOPPING.
           05 RG-SHOPPING-ID       PIC 9(05).
           05 RG-SHOPPING-ID-CLI   PIC 9(05).
           05 RG-SHOPPING-PROD     PIC X(15).
           05 RG-SHOPPING-PRICE    PIC 9(08)V99.

      **================== FD INVOICE BEGINNING =======================*
       FD  INVOICE.
       01  RG-INVOICE.
           05 RG-INVOICE-NAME      PIC X(20).
           05 RG-INVOICE-PROD      PIC X(15).
           05 RG-INVOICE-PRICE     PIC 9(08)V99.

      *----------------------------------------------------------------*
       WORKING-STORAGE                 SECTION.
      *----------------------------------------------------------------*
       01  FILLER          PIC X(047) VALUE
           "========== WORKING-STORAGE BEGINNING ==========".

      *----------------------------------------------------------------*
       01  FILLER          PIC X(047) VALUE
           "============ FILE-STATUS BEGINNING ============".
      *----------------------------------------------------------------*
       77  FS-CLIENTS-STATUS       PIC 9(02).
       77  FS-SHOPPING-STATUS      PIC 9(02).
       77  FS-INVOICE-STATUS       PIC 9(02).
      *----------------------------------------------------------------*
       01  FILLER          PIC X(057) VALUE
           "============ PROCESSMENT VARIABLES BEGINNING ============".
      *----------------------------------------------------------------*
       77  WRK-CLID        PIC 9(05)  VALUE ZEROS.
       77  WRK-CTRL-VAR    PIC X(01)  VALUE SPACES.
       77  WRK-PRICE-ED    PIC ZZ.ZZZ.ZZZ,ZZ.
      *----------------------------------------------------------------*
       01  FILLER          PIC X(052) VALUE
           "============ WARNING MESSAGES BEGINNING ============".
      *----------------------------------------------------------------*
       77  WRK-OPEN-ERROR       PIC X(20) VALUE "FILE WAS NOT OPENED!".
       77  WRK-NOT-EMPTY        PIC X(18) VALUE "FILE IS NOT EMPTY!".
      *----------------------------------------------------------------*
       PROCEDURE                       DIVISION.
      *----------------------------------------------------------------*
           PERFORM 0100-INIT.
           PERFORM 0200-PROCESS.
           PERFORM 0300-END.
           STOP RUN.
      *----------------------------------------------------------------*
       0100-INIT                       SECTION.
      **================ OPENING-SHOPPING BEGINNING ==================**
       0110-OPEN-SHOPPING.
           OPEN INPUT SHOPPING.
                IF FS-SHOPPING-STATUS NOT EQUAL 00
                   DISPLAY "SHOPPING: " WRK-OPEN-ERROR
                   DISPLAY "STATUS:   " FS-SHOPPING-STATUS
                  GOBACK
                END-IF.
      **================ OPENING-CLIENTS BEGINNING ===================**
       0120-OPEN-CLIENTS.
           OPEN INPUT CLIENTS.
                IF FS-CLIENTS-STATUS NOT EQUAL 00
                   DISPLAY "CLIENTS: " WRK-OPEN-ERROR
                   DISPLAY "STATUS:  " FS-CLIENTS-STATUS
                  GOBACK
                END-IF.
      **================ OPENING-INVOICE BEGINNING ===================**
       0130-OPEN-INVOICE.
           OPEN OUTPUT INVOICE.
                IF FS-INVOICE-STATUS NOT EQUAL 00
                   DISPLAY "INVOICE: " WRK-OPEN-ERROR
                   DISPLAY "STATUS:  " FS-INVOICE-STATUS
                  GOBACK
                END-IF.

       0200-PROCESS                    SECTION.
      **================ READING-CLIENTS BEGINNING ===================**
       0210-READING-CLIENTS.
           READ CLIENTS.
             IF FS-CLIENTS-STATUS EQUAL 00
                 PERFORM UNTIL FS-CLIENTS-STATUS NOT EQUAL 00
                      DISPLAY "RG CLIENTES ID:   " RG-CLIENTS-ID
                      DISPLAY "RG CLIENTES NOME: " RG-CLIENTS-NAME
                   READ CLIENTS

                 END-PERFORM
                   MOVE RG-CLIENTS-NAME TO RG-INVOICE-NAME
                   CLOSE CLIENTS
             END-IF.
      **================= READING SHOP BEGINING ======================**
       0220-READING-SHOPPING.
           DISPLAY "DIGITE O ID DO CLIENTE: "
             ACCEPT WRK-CLID.
           READ SHOPPING
             IF FS-SHOPPING-STATUS EQUAL 00
                PERFORM UNTIL FS-SHOPPING-STATUS NOT EQUAL 00
                   IF WRK-CLID EQUAL RG-SHOPPING-ID
                     DISPLAY "ID DA COMPRA:      " RG-SHOPPING-ID
                     DISPLAY "ID DO CLIENTE:     " RG-SHOPPING-ID-CLI
                     DISPLAY "PRODUTO:           " RG-SHOPPING-PROD
                     DISPLAY "PRECO:             " RG-SHOPPING-PRICE
                     DISPLAY "-----------------------------------------"
                       MOVE RG-SHOPPING-PROD  TO RG-INVOICE-PROD
                       MOVE RG-SHOPPING-PRICE TO WRK-PRICE-ED
                       PERFORM 0230-WRITING-INVOICE
                       CLOSE INVOICE
                       CLOSE SHOPPING
                   END-IF
                   READ SHOPPING
                END-PERFORM
                GOBACK
             END-IF.
      **================ WRITING-INVOICE BEGINING =====================*
       0230-WRITING-INVOICE.
           DISPLAY "MASK " WRK-PRICE-ED.
           STRING RG-CLIENTS-NAME      DELIMITED BY SIZE
                  RG-SHOPPING-PROD     DELIMITED BY SIZE
                  RG-SHOPPING-PRICE    DELIMITED BY SIZE
                  INTO RG-INVOICE.
           WRITE RG-INVOICE.
      *----------------------------------------------------------------*
       0300-END                        SECTION.
           CLOSE CLIENTS.
           CLOSE SHOPPING.
           CLOSE INVOICE.

      *----------------------------------------------------------------*
