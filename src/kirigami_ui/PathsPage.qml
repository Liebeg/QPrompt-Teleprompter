/****************************************************************************
 **
 ** QPrompt
 ** Copyright (C) 2023 Javier O. Cordero Pérez
 **
 ** This file is part of QPrompt.
 **
 ** This program is free software: you can redistribute it and/or modify
 ** it under the terms of the GNU General Public License as published by
 ** the Free Software Foundation, version 3 of the License.
 **
 ** This program is distributed in the hope that it will be useful,
 ** but WITHOUT ANY WARRANTY; without even the implied warranty of
 ** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 ** GNU General Public License for more details.
 **
 ** You should have received a copy of the GNU General Public License
 ** along with this program.  If not, see <http://www.gnu.org/licenses/>.
 **
 ****************************************************************************/

import QtQuick 2.12
import org.kde.kirigami 2.11 as Kirigami
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import QtQuick.Dialogs 1.3
import Qt.labs.settings 1.0

Kirigami.ScrollablePage {

    id: pathSettings

    property alias sofficePath: sofficePathField.text;
    property string currentlyBrowsing: "soffice";
    readonly property string sofficeActualPath: {
        if (Qt.platform.os === "osx")
            return sofficePath.concat("/Contents/MacOS/soffice");
        else
            return sofficePath;
    }

    title: i18n("External Tools")

    background: Rectangle {
        color: Kirigami.Theme.alternateBackgroundColor
    }

    Settings {
        id: pathSettingsStorage
        category: "paths"
        property alias soffice: pathSettings.sofficePath
    }
    ColumnLayout {
        id: path_settings
        width: parent.implicitWidth
        Kirigami.Heading {
            text: i18n("LibreOffice")
        }
        TextArea {
            background: Item{}
            readOnly: true
            wrapMode: TextEdit.Wrap
            text: i18n("QPrompt can make transparent use of LibreOffice to convert Microsoft Word, "
                       + "Open Document Format, and other office documents into a format QPrompt "
                       + "understands. Install LibreOffice and ensure this field points to its "
                       + "location, so QPrompt can open office documents.")
            Layout.fillWidth: true
        }
        RowLayout {
            Button {
                text: i18nc("Browse for PROGRAM", "Browse for %1", "LibreOffice")
                onPressed: {
                    pathSettings.currentlyBrowsing = "soffice";
                    pathsDialog.open();
                }
            }
            TextField {
                id: sofficePathField
                placeholderText: switch(Qt.platform.os) {
                                 case "windows":
                                     return "C:/Program Files/LibreOffice/program/soffice.exe";
                                 case "osx":
                                     return "/Applications/LibreOffice.app";
                                 default:
                                     // Linux, BSD, Unix, QNX...
                                     return "soffice";
                                 }
                text: ""
                Layout.fillWidth: true
                onEditingFinished: {
                    pathSettingsStorage.sync();
                }
            }
        }
    }

    FileDialog {
        id: pathsDialog
        title: i18nc("Browse for PROGRAM", "Browse for %1", pathSettings.currentlyBrowsing)
        selectExisting: true
        selectedNameFilter: nameFilters[0]
        nameFilters: [
            (Qt.platform.os === "windows"
             ? i18nc("Format name (FORMAT_EXTENSION)", "Executable (%1)", "EXE") + "(" + "*.exe *.EXE" + ")"
             : (Qt.platform.os === "osx"
                ? i18nc("Format name (FORMAT_EXTENSION)", "Executable (%1)", "APP") + "(" + "*.app *.APP" + ")"
                : i18nc("Format name (FORMAT_EXTENSION)", "Executable (%1)", "BIN") + "(" + "*.bin *.BIN *" + ")"
                )),
            i18nc("All file formats", "All Formats") + "(*.*)"
        ]
        //fileMode: Labs.FileDialog.OpenFile
        onAccepted: {
            if (pathSettings.currentlyBrowsing === "soffice")
                // Convert URL to scheme and remove scheme part (file://)
                pathSettings.sofficePath = pathsDialog.fileUrl.toString().slice(7);
            pathSettingsStorage.sync();
        }
    }
}
