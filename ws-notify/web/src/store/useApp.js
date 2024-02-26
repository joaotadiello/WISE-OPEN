import { create } from "zustand";

const useAppStore = create((set) => ({
    app: "desktop",
    setApp: (data) => set({ app: data }),
}));

export default useAppStore;
