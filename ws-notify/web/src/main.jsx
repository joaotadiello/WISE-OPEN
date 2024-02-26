import React from "react";
import ReactDOM from "react-dom/client";
import { NuiProvider } from "fivem-nui-react-lib";
import "./index.css";
import Notify from "./Components";

ReactDOM.createRoot(document.getElementById("root")).render(
    <React.StrictMode>
        <NuiProvider resource="wise-notifyItens" timeout={5000}>
            <Notify />
        </NuiProvider>
    </React.StrictMode>
);
