// Project2.cpp : Ce fichier contient la fonction 'main'. L'exécution du programme commence et se termine à cet endroit.
//


#define WIN32_LEAN_AND_MEAN

//#include <windows.h>
//#include <winsock2.h>
//#include <ws2tcpip.h>
#include <stdlib.h>
#include <stdio.h>
#include "pch.h"
#include "framework.h"
#include "Project2.h"
#include "nvdaController.h"
#include <mmsystem.h>



// Need to link with Ws2_32.lib
#pragma comment (lib, "Ws2_32.lib")
//#pragma comment (lib, "Mswsock.lib")
#pragma warning(disable:4996) 
#pragma import winmm.lib

using namespace std;

#define DEFAULT_BUFLEN 1024
//#define DEFAULT_PORT "12345"
int portno = 12345;

char poke_char_to_ascii_char[256] = {0};
void init_poke_char_to_ascii_char() {
    poke_char_to_ascii_char[0x00] = ' ';
    poke_char_to_ascii_char[0x01] = '?';
    poke_char_to_ascii_char[0x02] = '?';
    poke_char_to_ascii_char[0x03] = '?';
    poke_char_to_ascii_char[0x04] = (char)231; //ç
    poke_char_to_ascii_char[0x05] = (char)232; //è
    poke_char_to_ascii_char[0x06] = (char)233; //é
    poke_char_to_ascii_char[0x07] = (char)234; //ê
    poke_char_to_ascii_char[0x08] = '?';
    poke_char_to_ascii_char[0x09] = '?';
    poke_char_to_ascii_char[0x0A] = '?';
    poke_char_to_ascii_char[0x0B] = (char)238; //î
    poke_char_to_ascii_char[0x0C] = '?';
    poke_char_to_ascii_char[0x0D] = '?';
    poke_char_to_ascii_char[0x0E] = '?';
    poke_char_to_ascii_char[0x0F] = '?';
    poke_char_to_ascii_char[0x10] = '?';
    poke_char_to_ascii_char[0x11] = '?';
    poke_char_to_ascii_char[0x12] = '?';
    poke_char_to_ascii_char[0x13] = (char)251; //û
    poke_char_to_ascii_char[0x14] = (char)251; //û
    poke_char_to_ascii_char[0x15] = '?';
    poke_char_to_ascii_char[0x16] = (char)224; //à
    poke_char_to_ascii_char[0x17] = '?';
    poke_char_to_ascii_char[0x18] = '?';
    poke_char_to_ascii_char[0x19] = (char)231; //ç
    poke_char_to_ascii_char[0x1A] = (char)232; //è
    poke_char_to_ascii_char[0x1B] = (char)233; //é
    poke_char_to_ascii_char[0x1C] = (char)234; //ê
    poke_char_to_ascii_char[0x1D] = '?';
    poke_char_to_ascii_char[0x1E] = '?';
    poke_char_to_ascii_char[0x1F] = '?';
    poke_char_to_ascii_char[0x20] = (char)238; //î
    poke_char_to_ascii_char[0x21] = '?';
    poke_char_to_ascii_char[0x22] = '?';
    poke_char_to_ascii_char[0x23] = '?';
    poke_char_to_ascii_char[0x24] = '?';
    poke_char_to_ascii_char[0x25] = '?';
    poke_char_to_ascii_char[0x26] = '?';
    poke_char_to_ascii_char[0x27] = (char)249; //ù
    poke_char_to_ascii_char[0x28] = (char)251; //û
    poke_char_to_ascii_char[0x29] = '?';
    poke_char_to_ascii_char[0x2A] = '?';
    poke_char_to_ascii_char[0x2B] = '?';
    poke_char_to_ascii_char[0x2C] = '?';
    poke_char_to_ascii_char[0x2D] = '?';
    poke_char_to_ascii_char[0x2E] = '+';
    poke_char_to_ascii_char[0x34] = '?';
    poke_char_to_ascii_char[0x35] = '=';
    poke_char_to_ascii_char[0x36] = ';';
    poke_char_to_ascii_char[0x51] = '?';
    poke_char_to_ascii_char[0x52] = '?';
    poke_char_to_ascii_char[0x53] = '?';
    poke_char_to_ascii_char[0x54] = '?';
    poke_char_to_ascii_char[0x55] = '?';
    poke_char_to_ascii_char[0x56] = '?';
    poke_char_to_ascii_char[0x57] = '?';
    poke_char_to_ascii_char[0x58] = '?';
    poke_char_to_ascii_char[0x59] = '?';
    poke_char_to_ascii_char[0x5A] = '?';
    poke_char_to_ascii_char[0x5B] = '%';
    poke_char_to_ascii_char[0x5C] = '(';
    poke_char_to_ascii_char[0x5D] = ')';
    poke_char_to_ascii_char[0x68] = (char)226; //â
    poke_char_to_ascii_char[0x6F] = '?';
    poke_char_to_ascii_char[0x77] = '?';
    poke_char_to_ascii_char[0x79] = '?';
    poke_char_to_ascii_char[0x7A] = '?';
    poke_char_to_ascii_char[0x7B] = '?';
    poke_char_to_ascii_char[0x7C] = '?';
    poke_char_to_ascii_char[0x84] = '?';
    poke_char_to_ascii_char[0x85] = '<';
    poke_char_to_ascii_char[0x86] = '>';
    poke_char_to_ascii_char[0xA0] = '?';
    poke_char_to_ascii_char[0xA1] = '0';
    poke_char_to_ascii_char[0xA2] = '1';
    poke_char_to_ascii_char[0xA3] = '2';
    poke_char_to_ascii_char[0xA4] = '3';
    poke_char_to_ascii_char[0xA5] = '4';
    poke_char_to_ascii_char[0xA6] = '5';
    poke_char_to_ascii_char[0xA7] = '6';
    poke_char_to_ascii_char[0xA8] = '7';
    poke_char_to_ascii_char[0xA9] = '8';
    poke_char_to_ascii_char[0xAA] = '9';
    poke_char_to_ascii_char[0xAB] = '!';
    poke_char_to_ascii_char[0xAC] = '?';
    poke_char_to_ascii_char[0xAD] = '.';
    poke_char_to_ascii_char[0xAE] = '-';
    poke_char_to_ascii_char[0xAF] = '?';
    poke_char_to_ascii_char[0xB0] = '.';
    poke_char_to_ascii_char[0xB1] = '"';
    poke_char_to_ascii_char[0xB2] = '"';
    poke_char_to_ascii_char[0xB3] = '\'';
poke_char_to_ascii_char[0xB4] = '\'';
poke_char_to_ascii_char[0xB5] = '?';
poke_char_to_ascii_char[0xB6] = '?';
poke_char_to_ascii_char[0xB7] = '$';
poke_char_to_ascii_char[0xB8] = ',';
poke_char_to_ascii_char[0xB9] = '*';
poke_char_to_ascii_char[0xBA] = '/';
poke_char_to_ascii_char[0xBB] = 'A';
poke_char_to_ascii_char[0xBC] = 'B';
poke_char_to_ascii_char[0xBD] = 'C';
poke_char_to_ascii_char[0xBE] = 'D';
poke_char_to_ascii_char[0xBF] = 'E';
poke_char_to_ascii_char[0xC0] = 'F';
poke_char_to_ascii_char[0xC1] = 'G';
poke_char_to_ascii_char[0xC2] = 'H';
poke_char_to_ascii_char[0xC3] = 'I';
poke_char_to_ascii_char[0xC4] = 'J';
poke_char_to_ascii_char[0xC5] = 'K';
poke_char_to_ascii_char[0xC6] = 'L';
poke_char_to_ascii_char[0xC7] = 'M';
poke_char_to_ascii_char[0xC8] = 'N';
poke_char_to_ascii_char[0xC9] = 'O';
poke_char_to_ascii_char[0xCA] = 'P';
poke_char_to_ascii_char[0xCB] = 'Q';
poke_char_to_ascii_char[0xCC] = 'R';
poke_char_to_ascii_char[0xCD] = 'S';
poke_char_to_ascii_char[0xCE] = 'T';
poke_char_to_ascii_char[0xCF] = 'U';
poke_char_to_ascii_char[0xD0] = 'V';
poke_char_to_ascii_char[0xD1] = 'W';
poke_char_to_ascii_char[0xD2] = 'X';
poke_char_to_ascii_char[0xD3] = 'Y';
poke_char_to_ascii_char[0xD4] = 'Z';
poke_char_to_ascii_char[0xD5] = 'a';
poke_char_to_ascii_char[0xD6] = 'b';
poke_char_to_ascii_char[0xD7] = 'c';
poke_char_to_ascii_char[0xD8] = 'd';
poke_char_to_ascii_char[0xD9] = 'e';
poke_char_to_ascii_char[0xDA] = 'f';
poke_char_to_ascii_char[0xDB] = 'g';
poke_char_to_ascii_char[0xDC] = 'h';
poke_char_to_ascii_char[0xDD] = 'i';
poke_char_to_ascii_char[0xDE] = 'j';
poke_char_to_ascii_char[0xDF] = 'k';
poke_char_to_ascii_char[0xE0] = 'l';
poke_char_to_ascii_char[0xE1] = 'm';
poke_char_to_ascii_char[0xE2] = 'n';
poke_char_to_ascii_char[0xE3] = 'o';
poke_char_to_ascii_char[0xE4] = 'p';
poke_char_to_ascii_char[0xE5] = 'q';
poke_char_to_ascii_char[0xE6] = 'r';
poke_char_to_ascii_char[0xE7] = 's';
poke_char_to_ascii_char[0xE8] = 't';
poke_char_to_ascii_char[0xE9] = 'u';
poke_char_to_ascii_char[0xEA] = 'v';
poke_char_to_ascii_char[0xEB] = 'w';
poke_char_to_ascii_char[0xEC] = 'x';
poke_char_to_ascii_char[0xED] = 'y';
poke_char_to_ascii_char[0xEE] = 'z';
poke_char_to_ascii_char[0xEF] = '?';
poke_char_to_ascii_char[0xF0] = ':';
poke_char_to_ascii_char[0xF1] = '?';
poke_char_to_ascii_char[0xF2] = '?';
poke_char_to_ascii_char[0xF3] = '?';
poke_char_to_ascii_char[0xF4] = '?';
poke_char_to_ascii_char[0xF5] = '?';
poke_char_to_ascii_char[0xF6] = '?';
poke_char_to_ascii_char[0xF7] = '?';
poke_char_to_ascii_char[0xF8] = '?';
poke_char_to_ascii_char[0xF9] = '?';
poke_char_to_ascii_char[0xFA] = '{';
poke_char_to_ascii_char[0xFB] = '{';
poke_char_to_ascii_char[0xFC] = ' ';
poke_char_to_ascii_char[0xFD] = '?';
poke_char_to_ascii_char[0xFE] = ' ';
poke_char_to_ascii_char[0xFF] = ' ';
}

void convert_poke_string_to_ascii_string(char poke_str[], int len) {
    for (int i = 0; i < len; i++) {
        //cout << +(unsigned char)poke_str[i] << ",";
        poke_str[i] = poke_char_to_ascii_char[(unsigned char)poke_str[i]];
        //cout << +(unsigned char)poke_str[i] << ",";

        //cout << poke_str[i] << "|";
    }


    //cout << endl;
    //cout << "convert_poke_string_to_ascii_string done\n";
}

void remove_size_from_string(char str[]) {
    int i = 0;
    while (str[i] != ' ') {
        str[i] = ' ';
        i++;
    }
}

SOCKET ClientSocket = INVALID_SOCKET;
void clean_up() {
    // cleanup
    closesocket(ClientSocket);
    WSACleanup();

    cout << "exit";
    exit(0);
}

/*
LRESULT CALLBACK WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
    switch (uMsg)
    {
    case WM_CLOSE:
        if (MessageBox(hwnd, L"Really quit?", L"My application", MB_OKCANCEL) == IDOK)
        {
            clean_up(); //DestroyWindow(hwnd);
        }
        // Else: User canceled. Do nothing.
        return 0;
    }
}*/

int __cdecl main(void)
{
    SetConsoleTitle(L"Bizhawk Pokemon Access Gen3 sound controller");
    
    //atexit(clean_up);
    WSADATA wsaData;
    int iResult;

    SOCKET ListenSocket = INVALID_SOCKET;
    

    struct addrinfo* result = NULL;
    struct addrinfo hints;

    int iSendResult;
    char recvbuf[DEFAULT_BUFLEN];
    int recvbuflen = DEFAULT_BUFLEN;
    wchar_t text_wchar[DEFAULT_BUFLEN];
    size_t length = 0;

    unsigned char command = 0;

    init_poke_char_to_ascii_char();

    //cout << "V4" << endl;
    cout << "Starting Bizhawk Pokemon Gen3 Access script sound controller\n";

    //PlaySound(TEXT(" blip.wav"), NULL, SND_SYNC);

    long res = nvdaController_testIfRunning();
    if (res != 0) {
        //MessageBox(0, L"Error communicating with NVDA", L"Error", 0);
        cout << "Error communicating with NVDA, exiting..\n";
        MessageBox(NULL, L"Error communicating with NVDA, exiting..", L"Error!", MB_OK);
        return 1;
    }

    // Initialize Winsock
    iResult = WSAStartup(MAKEWORD(2, 2), &wsaData);
    if (iResult != 0) {
        cout << "WSAStartup failed with error: %d\n";
        MessageBox(NULL, L"WSAStartup failed", L"Error!", MB_OK);
        return 1;
    }

    SOCKADDR_IN addr;                     // The address structure for a TCP socket

    addr.sin_family = AF_INET;            // Address family  
    addr.sin_port = htons(portno);       // Assign port to this socket   
    addr.sin_addr.s_addr = inet_addr("127.0.0.1");

    // Create a SOCKET for connecting to server
    ListenSocket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP); //socket(result->ai_family, result->ai_socktype, result->ai_protocol);
    if (ListenSocket == INVALID_SOCKET) {
        printf("socket failed with error: %ld\n", WSAGetLastError());
        MessageBox(NULL, L"Create socket failed", L"Error!", MB_OK);
        //cout << "socket failed with error: %ld\n";
        //freeaddrinfo(result);
        WSACleanup();
        return 1;
    }

    

    // Setup the TCP listening socket
    //if (bind(s, (LPSOCKADDR)&addr, sizeof(addr)) == SOCKET_ERROR)
    iResult = bind(ListenSocket, (LPSOCKADDR)&addr, sizeof(addr));
    if (iResult == SOCKET_ERROR) {
        printf("bind failed with error: %d\n", WSAGetLastError());
        MessageBox(NULL, L"Bind socket failed", L"Error!", MB_OK);
        //cout << "bind failed with error: %d\n";
        //freeaddrinfo(result);
        closesocket(ListenSocket);
        WSACleanup();
        return 1;
    }

    //freeaddrinfo(result);

    iResult = listen(ListenSocket, SOMAXCONN);
    if (iResult == SOCKET_ERROR) {
        printf("listen failed with error: %d\n", WSAGetLastError());
        MessageBox(NULL, L"Listen socket failed", L"Error!", MB_OK);
        //cout << "listen failed with error: %d\n";
        closesocket(ListenSocket);
        WSACleanup();
        return 1;
    }


    cout << "Accept a client socket\n";
    // Accept a client socket
    ClientSocket = accept(ListenSocket, NULL, NULL);
    if (ClientSocket == INVALID_SOCKET) {
        printf("accept failed with error: %d\n", WSAGetLastError());
        MessageBox(NULL, L"Accept socket failed", L"Error!", MB_OK);
        //cout << "accept failed with error: %d\n";
        closesocket(ListenSocket);
        WSACleanup();
        return 1;
    }

    // No longer need server socket
    closesocket(ListenSocket);

    wcout << "Receiving...\n";

    // Receive until the peer shuts down the connection
    do {

        iResult = recv(ClientSocket, recvbuf, recvbuflen, 0);
        if (iResult > 0) {
            auto voice = [&]() {
                mbstowcs_s(&length, text_wchar, recvbuf, iResult); //

                nvdaController_speakText(text_wchar);

                wcout.write(text_wchar, length);
                cout << endl;
            };
            //printf("Bytes received: %d\n", iResult);
            
            //remove_size_from_string(recvbuf);
            
            //cout << ":" << recvbuf << endl;
            //mbstowcs_s(&length, text_wchar, recvbuf, iResult);
            //wcout << "::" << text_wchar << endl;


            command = recvbuf[0]; // -48;

            cout << "Data received, " << iResult << " bytes, type: " << +command << endl;

            recvbuf[0] = char(32);

            //convert_poke_string_to_ascii_string(recvbuf, iResult);
            //recvbuf[0] = ' ';
            //voice();


            if (command == 1) {
                convert_poke_string_to_ascii_string(recvbuf, iResult);
                recvbuf[0] = ' ';
                voice();
            } else if (command == 2) {
                voice();
            } else if (command == 3 or command == 4) {
                char* recvbuf2 = recvbuf +1;
                mbstowcs_s(&length, text_wchar, recvbuf2, iResult-1);
                DWORD play_style = SND_ASYNC;
                if(command == 4) play_style = SND_NOSTOP | SND_ASYNC;
                PlaySound(text_wchar, NULL, play_style);
                wcout << "Sound played :" << text_wchar << endl;
            }
        }
        else if (iResult == 0)
            printf("Connection closing...\n");
        else {
            printf("recv failed with error: %d\n", WSAGetLastError());
            //MessageBox(NULL, L"Receiv socket failed", L"Error!", MB_OK);
            closesocket(ClientSocket);
            WSACleanup();
            return 1;
        }

    } while (iResult > 0);

    // shutdown the connection since we're done
    iResult = shutdown(ClientSocket, SD_SEND);
    if (iResult == SOCKET_ERROR) {
        printf("shutdown failed with error: %d\n", WSAGetLastError());
        MessageBox(NULL, L"Socket shutdown failed", L"Error!", MB_OK);
        closesocket(ClientSocket);
        WSACleanup();
        return 1;
    }

    clean_up();
}