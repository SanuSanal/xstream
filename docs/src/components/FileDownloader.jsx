import React, { useState } from "react";

const APKDownloader = () => {

    const apkOptions = [
        { name: "arm64 v8a APK", file: "xstream-arm64-v8a-release.apk" },
        { name: "armeabi v7a APK", file: "xstream-armeabi-v7a-release.apk" },
        { name: "x86 APK", file: "xstream-x86_64-release.apk" },
    ];

    const [selectedApk, setSelectedApk] = useState(apkOptions[0]);

    const handleSelect = (apk) => {
        setSelectedApk(apk);
    };

    const handleDownload = () => {
        const apkPath = `/assets/${selectedApk.file}`;
        const link = document.createElement("a");
        link.href = apkPath;
        link.download = selectedApk.file;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    };

    return (
        <div className="btn-group">

            <div className="dropdown">
                <button
                    className="btn btn-secondary btn-lg dropdown-toggle"
                    type="button"
                    id="apkDropdown"
                    data-bs-toggle="dropdown"
                    aria-haspopup="true"
                    aria-expanded="false"
                >
                    {selectedApk.name}
                </button>
                <div className="dropdown-menu" aria-labelledby="apkDropdown">
                    {apkOptions.map((apk, index) => (
                        <button
                            key={index}
                            className="dropdown-item"
                            onClick={() => handleSelect(apk)}
                        >
                            {apk.name}
                        </button>
                    ))}
                </div>
            </div>

            <button className="btn btn-primary btn-lg" type="button" onClick={handleDownload}>
                Download
            </button>
        </div>
    );
};

export default APKDownloader;
