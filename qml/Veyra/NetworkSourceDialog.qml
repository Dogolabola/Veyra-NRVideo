// network dialog: source/settings logic is owned by this component.
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

DialogLayer {
    id: networkDialog
    objectName: "network-dialog"
    key: "network"
    glyph: "cast"
    title: qsTr("播放地址")
    sub: qsTr("直接打开 HTTP、HTTPS、RTSP、RTP、UDP 或 SRT 视频流")
    dialogWidth: 640
    onShownChanged: if (shown) Qt.callLater(() => {
        if (!networkDialog.shown) return
        if (networkAddress.text.length === 0) networkAddress.text = veyra.preferences.networkAddress || ""
        networkAddress.focusEditor()
    })
    actions: [{label:qsTr("取消")},{label:qsTr("打开"),primary:true,icon:"play"}]
    onActionTriggered: label => {
        if(label!==qsTr("打开")){dialogHost.close();return}
        // IRL: applied before opening so the first picture already uses it.
        if (veyra.preferences.networkIrl60 === true) {
            veyra.fgBackendName = "vfg"
            veyra.fgEnabled = true
            veyra.fgMultiplier = 2
        }
        if (!veyra.openNetworkAddress(networkAddress.text)) return
        veyra.setPreference("networkAddress", veyra.preferences.networkRemember === true ? networkAddress.text.trim() : "")
        if (veyra.preferences.networkIrl60 === true) veyra.setVirtualCameraEnabled(true)
        dialogHost.close()
    }
    DialogTextField {
        id: networkAddress
        objectName: "network-address"
        Layout.fillWidth: true
        placeholder: "https://… / rtsp://… / rtp://… / udp://… / srt://…"
    }
    Text {
        Layout.fillWidth: true
        text: qsTr("请使用直接媒体地址。RTP、UDP 和 SRT 地址需要包含端口。")
        wrapMode: Text.Wrap
        color: Theme.t3
        font.family: Theme.fontUi
        font.pixelSize: 12
    }
    VRow {
        label: qsTr("IRL 60 帧（SRT → OBS）")
        hint: qsTr("打开时启用 NVIDIA VFG 2X 和虚拟摄像机。30 帧输入输出 60 帧。")
        VSwitch {
            objectName: "network-irl60"
            checked: veyra.preferences.networkIrl60 === true
            onToggled: v => veyra.setPreference("networkIrl60", v)
        }
    }
    VRow {
        label: qsTr("记住地址")
        hint: qsTr("地址以明文保存在本机，可能包含推流密钥。")
        VSwitch {
            objectName: "network-remember"
            checked: veyra.preferences.networkRemember === true
            onToggled: v => veyra.setPreference("networkRemember", v)
        }
    }
    VRow {
        label: qsTr("直播时移")
        hint: qsTr("保留最近的直播内容。最多使用 256 MiB 内存，高码率时可回看时间会缩短。")
        VSeg {
            objectName: "network-timeshift"
            options: [{id:"0",label:qsTr("关闭","off")},{id:"60",label:qsTr("1 分钟")},
                      {id:"120",label:qsTr("2 分钟")},{id:"300",label:qsTr("5 分钟")}]
            current: String(veyra.preferences.networkTimeshift || 0)
            onPicked: id => veyra.setPreference("networkTimeshift", Number(id))
        }
    }
}
