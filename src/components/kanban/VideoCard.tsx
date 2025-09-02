import { Clock, User, Hash } from 'lucide-react';
import type { Video } from '@/contexts/AppContext';
import { VideoCardActions } from './VideoCardActions';
import { Copy, ExternalLink } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { toast } from '@/hooks/use-toast';
import { useApp } from '@/contexts/AppContext';

interface VideoCardProps {
  video: Video;
  onDragStart: (video: Video) => void;
  onDragEnd: () => void;
  onThumbnailToggle: (videoId: string) => void;
}

const getChannelColor = (canalCor: string) => {
  return 'border-l-4';
};

export const VideoCard = ({ video, onDragStart, onDragEnd, onThumbnailToggle }: VideoCardProps) => {
  const { canais } = useApp();
  
  const canal = canais.find(c => c.id === video.canal_id);
  const canalCor = canal?.cor || '#8B5CF6';
  
  const handleDragStart = (e: React.DragEvent) => {
    onDragStart(video);
    e.dataTransfer.effectAllowed = 'move';
  };

  return (
    <div
      draggable
      onDragStart={handleDragStart}
      onDragEnd={onDragEnd}
      className={`video-card ${getChannelColor(canalCor)} relative pb-12`}
      style={{ borderLeftColor: canalCor }}
    >
      {/* Video Title with Copy */}
      <div 
        className="mb-3 cursor-pointer"
        onClick={(e) => {
          e.stopPropagation();
          const content = video.titulo + (video.responsavel_nome ? `\n\nResponsável: ${video.responsavel_nome}` : '');
          navigator.clipboard.writeText(content);
          toast({
            title: "Copiado!",
            description: "Título e informações copiados para a área de transferência"
          });
        }}
        title="Clique para copiar título e informações"
      >
        <h3 className="font-medium text-foreground line-clamp-2 hover:text-primary transition-colors">
          {video.titulo}
        </h3>
      </div>

      {/* Google Drive Link */}
      {video.google_drive_link && (
        <div className="mb-3">
          <Button
            size="sm"
            variant="outline"
            onClick={() => window.open(video.google_drive_link, '_blank')}
            className="text-xs"
          >
            <ExternalLink className="w-3 h-3 mr-1" />
            Google Drive
          </Button>
        </div>
      )}

      {/* Thumbnail Checkbox */}
      <div className="mb-3 relative z-10">
        <button
          onClick={(e) => {
            e.stopPropagation();
            onThumbnailToggle(video.id);
          }}
          className={`flex items-center gap-2 text-xs px-2 py-1 rounded border transition-colors ${
            video.thumbnail_pronta 
              ? 'bg-success/20 border-success text-success' 
              : 'bg-muted border-border text-muted-foreground hover:border-primary'
          }`}
        >
          <div className={`w-3 h-3 rounded border flex items-center justify-center ${
            video.thumbnail_pronta ? 'bg-success border-success' : 'border-muted-foreground'
          }`}>
            {video.thumbnail_pronta && <span className="text-white text-xs">✓</span>}
          </div>
          <span>Thumbnail {video.thumbnail_pronta ? 'Pronta' : 'Pendente'}</span>
        </button>
      </div>

      {/* Channel Badge */}
      <div className="flex items-center gap-2 mb-2">
        <div 
          className="w-3 h-3 rounded-full"
          style={{ backgroundColor: canalCor }}
        />
        <span className="text-xs font-medium text-primary">
          {video.canal_nome}
        </span>
      </div>

      {/* Assignee */}
      {video.responsavel_nome && (
        <div className="flex items-center gap-2 mb-2">
          <User className="w-3 h-3 text-muted-foreground" />
          <span className="text-xs text-muted-foreground">
            {video.responsavel_nome}
          </span>
        </div>
      )}

      {/* Created Date */}
      <div className="flex items-center gap-2 text-xs text-muted-foreground mb-2">
        <Clock className="w-3 h-3" />
        <span>
          {video.data_criacao.toLocaleDateString('pt-BR')}
        </span>
      </div>
      
      {/* Status Badge */}
      <div className={`inline-flex items-center px-2 py-1 rounded-md text-xs font-medium border status-${video.status}`}>
        {video.status.charAt(0).toUpperCase() + video.status.slice(1)}
      </div>
      
      {/* Video Actions - positioned after all content to avoid z-index conflicts */}
      <VideoCardActions video={video} onThumbnailToggle={onThumbnailToggle} />
    </div>
  );
};
