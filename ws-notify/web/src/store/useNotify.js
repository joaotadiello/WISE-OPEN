import {create} from 'zustand';

const useNotifyStore = create((set) => ({
    notifys: [],
    config:{
        imagesUrl: 'http://localhost/itens/',
    },
    setConfig: (data) => set((state) => {
        return {
            config: data
        }
    }),
    addNotify: (data) => set((state) => {
        return {
            notifys: [...state.notifys, data]
        }
    }),
    removeNotify: (id) => set((state) => {
        return {
            notifys: state.notifys.filter((item) => item.id === id) 
        }
    }),
}));

export default useNotifyStore;
