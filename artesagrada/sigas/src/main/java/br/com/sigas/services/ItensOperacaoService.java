package br.com.sigas.services;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import br.com.sigas.entities.ItensOperacao;
import br.com.sigas.repositories.ItensOperacaoRepository;
import jakarta.transaction.Transactional;

@Service
public class ItensOperacaoService {

    @Autowired
    private ItensOperacaoRepository itensOperacaoRepository;

    @Transactional
    public void inserirItemOperacao(ItensOperacao item) {
        itensOperacaoRepository.inserirItemOperacao(
                item.getOperacao().getId_operacao(),
                item.getProduto().getId_produto(),
                item.getQuantidade(),
                item.getPreco_unitario());
    }

    @Transactional
    public void atualizarItemOperacao(Long idItemOperacao, ItensOperacao itemAtualizado) {
        itensOperacaoRepository.atualizarItemOperacao(
                idItemOperacao,
                itemAtualizado.getQuantidade(),
                itemAtualizado.getPreco_unitario());
    }

    @Transactional
    public void deletarItemOperacao(Long idItemOperacao) {
        itensOperacaoRepository.deletarItemOperacao(idItemOperacao);
    }
}
