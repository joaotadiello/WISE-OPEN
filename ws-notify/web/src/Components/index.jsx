import { useEffect, useCallback,useState } from "react";
import useNotifyStore from "../store/useNotify";
import { Container, ContainerItem, Main } from "./styled";
import { debugData } from "../utils/debugData";
import { useNuiEvent } from "../hooks/useNuiEvent";
import {fetchNui} from "../utils/fetchNui";

debugData([
    {
        action: "0x771F3335",
        data: {
            image: "adrenalina",
            name: "Adrenalina",
            amount: 1,
            action: "Pegou",
        },
    }
],1000)

const Item = ({ itemId, action, name, image, amount, cb }) => {
    const config = useNotifyStore((state) => state.config)
    useEffect(() => {
        setTimeout(() => {
            cb(itemId)
        }, 3000);
    }, []);

    return (
        <ContainerItem>
            <img src={config.imagesUrl + image + ".png"} alt="image" />
            <h1>{action}</h1>
            <span>{amount}x {name}</span>
            <div className="timer" />
        </ContainerItem>
    );
};

const Notify = () => {
    const list = useNotifyStore((state) => state.notifys)
    const addNotify = useNotifyStore((state) => state.addNotify)
    const removeNotify = useNotifyStore((state) => state.removeNotify)
    const setConfig = useNotifyStore((state) => state.setConfig)

    const [auth, setAuth] = useState(true)

    useEffect(() => {
        fetchNui("0xA524CA30").then((data) => {
            setConfig(data["0x47827583"])
            setAuth(data["0x1C31B317"])
        })
    }, []);

    useNuiEvent("0x771F3335", (data) => {
        addNotify({...data, id: Date.now()})
    });

    const remove = useCallback((id) => {
        removeNotify(id)
    }, [list]);

    return (
        <Main style={{
            display: auth ? "flex" : "none"
        }}>
            <Container width={list.length * 6.875+"em"}>
                {list.map((item, index) => (
                    <Item
                        key={index}
                        itemKey={item.id}
                        image={item.image}
                        name={item.name}
                        amount={item.amount}
                        action={item.action}
                        cb={remove}
                    />
                ))}
            </Container>
        </Main>
    );
};

export default Notify;