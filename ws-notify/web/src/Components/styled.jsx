import styled, { keyframes } from "styled-components";

const animation = keyframes`
    0% {
        width: 100%;
    }
    100% {
        width: 0%;
    }
`

const fadeIn = keyframes`
    0% {
        opacity: 0;
        filter: grayscale(1);
    }
    100% {
        opacity: 1;
        filter: grayscale(0);

    }
`

const fadeOut = keyframes`
    0% {
        opacity: 1;
    }
    100% {
        opacity: 0;
    }
`

export const Main = styled.div`
    width: 100vw;
    height: 100vh;
    display: flex;
    justify-content: center;
    align-items: flex-end;
    padding-bottom: 5em;
`

export const Container = styled.div`
    width: ${props => props.width ? props.width : "auto"};
    min-width: 6.875em;
    height: 6.25em;
    display: flex;
    flex-direction: row;
    gap: 0.5em;
    transition: all .25s ease-in;
`

export const ContainerItem = styled.div`
    /* min-width: 6.875em; */
    height: 7.5em;
    border-radius: 3px;
    border: 1px solid rgba(255, 255, 255, 0.15);
    background: rgba(255, 255, 255, 0.20);
    display: flex;
    justify-content: center;
    align-items: center;
    flex-direction: column;
    position: relative;
    overflow: hidden;
    padding: 1em;
    animation:  ${fadeIn} 1s forwards 3s, 1s ${fadeOut} 1s forwards;
    
    & > img {
        max-width: 4em;
        height: 3.5em;
        filter: contrast(1.1) brightness(1.2) saturate(1.4);
    }

    & > h1 {
        margin-top: .5em;
        color: #FFF;
        text-align: center;
        font-size: 0.9375em;
        font-style: normal;
        font-weight: 800;
        line-height: normal;
        text-transform: uppercase;
        font-family: 'Akrobat ExtraBold', sans-serif;
    }

    & > span {
        color: #FFF;
        font-size: 0.875em;
        font-family: 'Akrobat Light', sans-serif;
        font-style: normal;
        font-weight: 400;
        line-height: normal;
        margin-bottom: 1em;
        letter-spacing: 0.05em;
    }

    & > .timer {
        width: 100%;
        height: 0.375em;
        background: #00F8B9;
        position: absolute;
        bottom: 0;
        left: 0;
        animation: ${animation} 3s forwards;
    }
`

