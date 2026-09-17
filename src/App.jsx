import { useEffect, useRef, useState } from 'react';
import { VoiceBeam, useMicrophone } from 'voice-glow';

const ACTIONS = {
  discover: [
    { id: 'contact', label: 'Contact', icon: 'contact', variant: 'neutral' },
    { id: 'scan', label: 'Scan QR', icon: 'qr', variant: 'neutral' },
    { id: 'close', label: 'Close', icon: 'close', variant: 'close' },
  ],
  qr: [
    { id: 'close', label: 'Close', icon: 'close', variant: 'close' },
    { id: 'contact', label: 'Contact', icon: 'contact', variant: 'neutral' },
    { id: 'my-qr', label: 'My QR', icon: 'qr', variant: 'neutral' },
  ],
  payment: [
    { id: 'pay', label: 'Pay', icon: 'pay', variant: 'pay' },
    { id: 'request', label: 'Request', icon: 'request', variant: 'request' },
    { id: 'close', label: 'Close', icon: 'close', variant: 'close' },
  ],
};

function Icon({ name }) {
  const common = {
    'aria-hidden': true,
    fill: 'none',
    viewBox: '0 0 24 24',
    width: 18,
    height: 18,
  };

  if (name === 'close') {
    return (
      <svg {...common} stroke="currentColor" strokeWidth="1.8" strokeLinecap="round">
        <path d="m6 6 12 12M18 6 6 18" />
      </svg>
    );
  }

  if (name === 'contact') {
    return (
      <svg {...common} stroke="currentColor" strokeWidth="1.7">
        <circle cx="12" cy="12" r="8.5" />
        <circle cx="12" cy="9.5" r="2.5" />
        <path d="M7.8 17.2c.8-2.1 2.2-3.2 4.2-3.2s3.4 1.1 4.2 3.2" strokeLinecap="round" />
      </svg>
    );
  }

  if (name === 'qr') {
    return (
      <svg {...common} stroke="currentColor" strokeWidth="1.6" strokeLinecap="round" strokeLinejoin="round">
        <path d="M4.5 4.5h5v5h-5zM14.5 4.5h5v5h-5zM4.5 14.5h5v5h-5z" />
        <path d="M14.5 14.5h2.2v2.2h-2.2zM17.3 17.3h2.2v2.2h-2.2zM14.5 19.5h2.2M19.5 14.5v1.3" />
      </svg>
    );
  }

  if (name === 'pay') {
    return (
      <svg {...common} stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round">
        <path d="M6.5 17.5 17.5 6.5M9 6.5h8.5V15" />
      </svg>
    );
  }

  if (name === 'request') {
    return (
      <svg {...common} stroke="currentColor" strokeWidth="1.9" strokeLinecap="round" strokeLinejoin="round">
        <path d="m17.5 6.5-11 11M15 17.5H6.5V9" />
      </svg>
    );
  }

  if (name === 'mic') {
    return (
      <svg {...common} stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round">
        <rect x="8.3" y="3.5" width="7.4" height="11.2" rx="3.7" />
        <path d="M5.5 11.6a6.5 6.5 0 0 0 13 0M12 18.1v3M8.8 21.1h6.4" />
      </svg>
    );
  }

  return (
    <svg {...common} stroke="currentColor" strokeWidth="1.7" strokeLinecap="round" strokeLinejoin="round">
      <path d="m5 5 14 14M19 5 5 19" />
      <path d="M5.5 11.6a6.5 6.5 0 0 0 13 0M12 18.1v3M8.8 21.1h6.4" />
    </svg>
  );
}

function ChatInput({ phase, onSelect }) {
  return (
    <div className={`chat-input chat-input--${phase}`} role="group" aria-label="Contextual actions">
      {ACTIONS[phase].map((action) => (
        <button
          key={action.id}
          className={`action action--${action.variant}`}
          type="button"
          aria-label={action.label}
          onClick={() => onSelect(action)}
        >
          <Icon name={action.icon} />
          {action.variant !== 'close' && <span>{action.label}</span>}
        </button>
      ))}
    </div>
  );
}

function App() {
  const mic = useMicrophone();
  const [phase, setPhase] = useState('qr');
  const [processing, setProcessing] = useState(false);
  const [message, setMessage] = useState('');
  const manualLevel = useRef(0.035);
  const timeoutRef = useRef(null);

  useEffect(() => {
    let frame;

    const animateFallbackLevel = (time) => {
      const breathing = 0.035 + (Math.sin(time / 620) + 1) * 0.012;
      const target = processing ? 0.48 + (Math.sin(time / 240) + 1) * 0.1 : breathing;
      manualLevel.current += (target - manualLevel.current) * 0.09;
      frame = requestAnimationFrame(animateFallbackLevel);
    };

    frame = requestAnimationFrame(animateFallbackLevel);
    return () => cancelAnimationFrame(frame);
  }, [processing]);

  useEffect(() => () => window.clearTimeout(timeoutRef.current), []);

  const handleAction = (action) => {
    window.clearTimeout(timeoutRef.current);

    switch (action.id) {
      case 'close':
        setProcessing(false);
        setPhase('discover');
        setMessage('');
        break;
      case 'contact':
        setPhase((current) => (current === 'discover' ? 'qr' : 'discover'));
        setMessage('');
        break;
      case 'scan':
        setPhase('qr');
        setMessage('');
        break;
      case 'my-qr':
        setPhase('payment');
        setMessage('');
        break;
      case 'pay':
      case 'request':
        setProcessing(true);
        setMessage(`${action.label} is ready`);
        timeoutRef.current = window.setTimeout(() => {
          setProcessing(false);
          setPhase('discover');
          setMessage('');
        }, 1200);
        break;
      default:
        break;
    }
  };

  const toggleMicrophone = async () => {
    if (mic.state === 'live') {
      mic.stop();
      setMessage('');
      return;
    }

    try {
      await mic.start();
      setMessage('Listening');
    } catch {
      setMessage('Allow microphone access to listen');
    }
  };

  const isLive = mic.state === 'live';

  return (
    <main className="app-shell">
      <section className={`glass-card glass-card--${phase} ${processing ? 'is-processing' : ''}`} aria-label="SWUI contextual action demo">
        <div className="ambient-light ambient-light--green" />
        <div className="ambient-light ambient-light--blue" />

        <div className="stage">
          <VoiceBeam
            type="default"
            theme="light"
            stream={isLive ? mic.stream : undefined}
            level={() => manualLevel.current}
            processing={processing}
            colorVariant="colorful"
            colors={['#54ee9b', '#75bdff', '#d69aff', '#ff9fce']}
            bandColors={{
              core: '#ffffff',
              above: '#63edaa',
              mid: '#76bfff',
              below: '#e2b7ff',
            }}
            sensitivity={1.2}
            threshold={0.025}
            attack={0.08}
            release={0.24}
            reach={0.84}
            spread={0.86}
            flow={0.18}
            bend={0.12}
            idle={0.06}
            strength={0.92}
          >
            <ChatInput phase={phase} onSelect={handleAction} />
          </VoiceBeam>

          <button
            className={`listen-button ${isLive ? 'is-live' : ''}`}
            type="button"
            aria-pressed={isLive}
            onClick={toggleMicrophone}
          >
            <Icon name={isLive ? 'mic-off' : 'mic'} />
            <span>{isLive ? 'Stop' : 'Listen'}</span>
          </button>

          <p className="sr-only" aria-live="polite">{message}</p>
        </div>
      </section>
    </main>
  );
}

export default App;
